-- T-3 Attendance Confirmation RPC
-- Confirms a participant's attendance for a lobby

CREATE OR REPLACE FUNCTION confirm_attendance(
  p_lobby_id UUID,
  p_user_id UUID
) RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_lobby record;
  v_participant record;
  v_hours_until numeric;
BEGIN
  -- Lock and fetch lobby
  SELECT * INTO v_lobby FROM lobbies WHERE id = p_lobby_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lobby not found';
  END IF;

  -- Check lobby is confirmed status
  IF v_lobby.status NOT IN ('open', 'confirmed') THEN
    RAISE EXCEPTION 'Lobby is not in a confirmable state';
  END IF;

  -- Fetch participant
  SELECT * INTO v_participant FROM lobby_participants
  WHERE lobby_id = p_lobby_id AND user_id = p_user_id
  AND status IN ('joined', 'confirmed')
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'You are not a participant in this lobby';
  END IF;

  -- Update participant status to confirmed
  UPDATE lobby_participants
  SET status = 'confirmed',
      confirmed_at = NOW(),
      updated_at = NOW()
  WHERE id = v_participant.id;

  RETURN 'confirmed';
END;
$$;

-- Auto-remove unconfirmed players RPC
-- Called at match time to remove players who didn't confirm attendance
-- and apply reliability penalties

CREATE OR REPLACE FUNCTION remove_unconfirmed_players(
  p_lobby_id UUID
) RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_lobby record;
  v_removed integer := 0;
  v_participant record;
  v_waitlisted record;
BEGIN
  SELECT * INTO v_lobby FROM lobbies WHERE id = p_lobby_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lobby not found';
  END IF;

  -- Find all unconfirmed participants (status = 'joined' but not 'confirmed')
  FOR v_participant IN
    SELECT * FROM lobby_participants
    WHERE lobby_id = p_lobby_id AND status = 'joined'
    FOR UPDATE
  LOOP
    -- Mark as no_show
    UPDATE lobby_participants
    SET status = 'no_show', left_at = NOW(), updated_at = NOW()
    WHERE id = v_participant.id;

    -- Record reliability event
    INSERT INTO reliability_events (user_id, lobby_id, event_type, score_delta, description)
    VALUES (v_participant.user_id, p_lobby_id, 'no_show', -15, 'Failed to confirm attendance');

    -- Update reliability score
    UPDATE profiles
    SET reliability_score = GREATEST(0, reliability_score - 15),
        updated_at = NOW()
    WHERE id = v_participant.user_id;

    -- Try to promote from waitlist
    SELECT * INTO v_waitlisted FROM lobby_participants
    WHERE lobby_id = p_lobby_id AND status = 'waitlisted'
    ORDER BY joined_at ASC LIMIT 1
    FOR UPDATE;

    IF FOUND THEN
      UPDATE lobby_participants SET status = 'joined' WHERE id = v_waitlisted.id;
    ELSE
      UPDATE lobbies SET current_players = GREATEST(0, current_players - 1) WHERE id = p_lobby_id;
    END IF;

    v_removed := v_removed + 1;
  END LOOP;

  RETURN v_removed;
END;
$$;
