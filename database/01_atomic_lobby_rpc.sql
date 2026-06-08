-- Atomic RPC functions for joining and leaving lobbies to prevent race conditions

CREATE OR REPLACE FUNCTION join_lobby_atomic(
  p_lobby_id UUID,
  p_user_id UUID
) RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_lobby record;
  v_status participant_status;
BEGIN
  -- Lock the row
  SELECT * INTO v_lobby FROM lobbies WHERE id = p_lobby_id FOR UPDATE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lobby not found';
  END IF;
  
  IF v_lobby.current_players >= v_lobby.max_players THEN
    v_status := 'waitlisted';
  ELSE
    v_status := 'joined';
    UPDATE lobbies SET current_players = current_players + 1 WHERE id = p_lobby_id;
  END IF;
  
  INSERT INTO lobby_participants (lobby_id, user_id, status)
  VALUES (p_lobby_id, p_user_id, v_status);
  
  RETURN v_status;
END;
$$;

CREATE OR REPLACE FUNCTION leave_lobby_atomic(
  p_lobby_id UUID,
  p_user_id UUID
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_participant record;
  v_waitlisted record;
BEGIN
  -- Lock participant row to ensure it exists and prevent concurrent deletes
  SELECT * INTO v_participant FROM lobby_participants 
  WHERE lobby_id = p_lobby_id AND user_id = p_user_id FOR UPDATE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Not in lobby';
  END IF;
  
  -- Remove the participant
  DELETE FROM lobby_participants WHERE id = v_participant.id;
  
  IF v_participant.status = 'joined' THEN
    -- Lock the lobby row to update player count
    PERFORM * FROM lobbies WHERE id = p_lobby_id FOR UPDATE;

    -- Try to promote a waitlisted user
    SELECT * INTO v_waitlisted FROM lobby_participants 
    WHERE lobby_id = p_lobby_id AND status = 'waitlisted' 
    ORDER BY joined_at ASC LIMIT 1 FOR UPDATE;
    
    IF FOUND THEN
      UPDATE lobby_participants SET status = 'joined' WHERE id = v_waitlisted.id;
    ELSE
      -- No waitlisted users, decrement current_players
      UPDATE lobbies SET current_players = current_players - 1 WHERE id = p_lobby_id;
    END IF;
  END IF;
END;
$$;
