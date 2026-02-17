CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE sport_type AS ENUM (
    'futsal', 'basketball', 'badminton', 'volleyball', 'tennis', 'tableTennis'
);

CREATE TYPE skill_level AS ENUM (
    'beginner', 'intermediate', 'advanced'
);

CREATE TYPE user_role AS ENUM (
    'player', 'host', 'admin'
);

CREATE TYPE lobby_status AS ENUM (
    'open', 'confirmed', 'in_progress', 'finished', 'settled', 'cancelled'
);

CREATE TYPE participant_status AS ENUM (
    'joined', 'waitlisted', 'confirmed', 'removed', 'left', 'no_show'
);

CREATE TYPE transaction_type AS ENUM (
    'top_up', 'deposit_hold', 'deposit_release', 'deposit_forfeit', 'refund'
);

CREATE TYPE payment_status AS ENUM (
    'pending', 'success', 'failed', 'expired', 'refunded'
);

CREATE TYPE match_result AS ENUM (
    'win', 'loss', 'draw'
);

CREATE TABLE profiles (
    id                  UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email               TEXT NOT NULL UNIQUE,
    full_name           TEXT,
    nim                 TEXT UNIQUE CONSTRAINT chk_nim_format CHECK (nim ~ '^\d{10}$'),
    campus              TEXT,
    role                user_role NOT NULL DEFAULT 'player',
    bio                 TEXT DEFAULT '',
    avatar_url          TEXT,
    sport_preferences   TEXT[] DEFAULT '{}',
    skill_levels        JSONB DEFAULT '{}'::JSONB,
    reliability_score   INT NOT NULL DEFAULT 100 CHECK (reliability_score BETWEEN 0 AND 100),
    sportsmanship_rating NUMERIC(3,2) NOT NULL DEFAULT 5.00 CHECK (sportsmanship_rating BETWEEN 0 AND 5),
    total_matches_played INT NOT NULL DEFAULT 0,
    total_wins          INT NOT NULL DEFAULT 0,
    total_losses        INT NOT NULL DEFAULT 0,
    is_onboarded        BOOLEAN NOT NULL DEFAULT FALSE,
    is_suspended        BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_campus ON profiles(campus);
CREATE INDEX idx_profiles_nim ON profiles(nim);

CREATE TABLE user_sport_ratings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    sport           sport_type NOT NULL,
    elo_rating      INT NOT NULL DEFAULT 1000,
    matches_played  INT NOT NULL DEFAULT 0,
    wins            INT NOT NULL DEFAULT 0,
    losses          INT NOT NULL DEFAULT 0,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, sport)
);

CREATE INDEX idx_sport_ratings_leaderboard ON user_sport_ratings(sport, elo_rating DESC);

CREATE TABLE fields (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    google_place_id TEXT UNIQUE,
    name            TEXT NOT NULL,
    address         TEXT NOT NULL,
    city            TEXT,
    latitude        DOUBLE PRECISION NOT NULL,
    longitude       DOUBLE PRECISION NOT NULL,
    sport_types     sport_type[] DEFAULT '{}',
    price_per_hour  NUMERIC(12,2),
    image_url       TEXT,
    google_rating   NUMERIC(3,2),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fields_location ON fields USING GIST (point(longitude, latitude));

CREATE TABLE lobbies (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    field_id            UUID REFERENCES fields(id),
    title               TEXT NOT NULL,
    sport               sport_type NOT NULL,
    description         TEXT DEFAULT '',
    scheduled_at        TIMESTAMPTZ NOT NULL,
    duration_minutes    INT NOT NULL DEFAULT 60,
    min_players         INT NOT NULL DEFAULT 2,
    max_players         INT NOT NULL DEFAULT 10,
    current_players     INT NOT NULL DEFAULT 0,
    min_elo             INT,
    max_elo             INT,
    deposit_amount      NUMERIC(12,2) NOT NULL DEFAULT 0,
    host_deposit_amount NUMERIC(12,2),
    status              lobby_status NOT NULL DEFAULT 'open',
    latitude            DOUBLE PRECISION,
    longitude           DOUBLE PRECISION,
    confirmed_at        TIMESTAMPTZ,
    finished_at         TIMESTAMPTZ,
    settled_at          TIMESTAMPTZ,
    cancelled_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lobbies_status ON lobbies(status);
CREATE INDEX idx_lobbies_sport ON lobbies(sport);
CREATE INDEX idx_lobbies_scheduled ON lobbies(scheduled_at);
CREATE INDEX idx_lobbies_host ON lobbies(host_id);

CREATE TABLE lobby_participants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id        UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status          participant_status NOT NULL DEFAULT 'joined',
    team            TEXT CHECK (team IN ('A', 'B')),
    position        INT,
    deposit_held    BOOLEAN NOT NULL DEFAULT FALSE,
    confirmed_at    TIMESTAMPTZ,
    must_confirm_by TIMESTAMPTZ,
    joined_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    left_at         TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(lobby_id, user_id)
);

CREATE INDEX idx_participants_lobby ON lobby_participants(lobby_id, status);
CREATE INDEX idx_participants_user ON lobby_participants(user_id);

CREATE TABLE credit_wallets (
    user_id     UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    balance     NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    held        NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (held >= 0),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE credit_transactions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type            transaction_type NOT NULL,
    amount          NUMERIC(14,2) NOT NULL,
    balance_after   NUMERIC(14,2),
    reference_id    UUID,
    description     TEXT DEFAULT '',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions_user ON credit_transactions(user_id, created_at DESC);

CREATE TABLE payments (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    midtrans_order_id   TEXT UNIQUE,
    midtrans_transaction_id TEXT,
    amount              NUMERIC(14,2) NOT NULL,
    status              payment_status NOT NULL DEFAULT 'pending',
    payment_method      TEXT,
    snap_token          TEXT,
    snap_redirect_url   TEXT,
    raw_response        JSONB,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_user ON payments(user_id, created_at DESC);

CREATE TABLE reliability_events (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    lobby_id        UUID REFERENCES lobbies(id),
    event_type      TEXT NOT NULL,
    score_delta     INT NOT NULL DEFAULT 0,
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reliability_user ON reliability_events(user_id, created_at DESC);

CREATE TABLE chat_messages (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id    UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    sender_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content     TEXT NOT NULL,
    is_system   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_lobby ON chat_messages(lobby_id, created_at);

CREATE TABLE matches (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id        UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    sport           sport_type NOT NULL,
    played_at       TIMESTAMPTZ NOT NULL,
    duration_minutes INT,
    team_a_score    INT,
    team_b_score    INT,
    elo_changes     JSONB DEFAULT '{}'::JSONB,
    settled         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_matches_lobby ON matches(lobby_id);

CREATE TABLE match_participants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    team            TEXT CHECK (team IN ('A', 'B')),
    result          match_result,
    elo_before      INT,
    elo_after       INT,
    elo_delta       INT,

    UNIQUE(match_id, user_id)
);

CREATE INDEX idx_match_participants_user ON match_participants(user_id);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT;
BEGIN
    FOR t IN SELECT unnest(ARRAY[
        'profiles', 'fields', 'lobbies', 'lobby_participants',
        'credit_wallets', 'payments', 'user_sport_ratings'
    ]) LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_%s_updated_at BEFORE UPDATE ON %I
             FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()', t, t);
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION check_lobby_time_conflict()
RETURNS TRIGGER AS $$
DECLARE
    new_start TIMESTAMPTZ;
    new_end   TIMESTAMPTZ;
BEGIN
    SELECT scheduled_at, scheduled_at + (duration_minutes || ' minutes')::INTERVAL
    INTO new_start, new_end
    FROM lobbies WHERE id = NEW.lobby_id;

    IF EXISTS (
        SELECT 1 FROM lobby_participants lp
        JOIN lobbies l ON l.id = lp.lobby_id
        WHERE lp.user_id = NEW.user_id
          AND lp.lobby_id != NEW.lobby_id
          AND lp.status IN ('joined', 'confirmed')
          AND l.status IN ('open', 'confirmed', 'in_progress')
          AND l.scheduled_at < new_end
          AND (l.scheduled_at + (l.duration_minutes || ' minutes')::INTERVAL) > new_start
    ) THEN
        RAISE EXCEPTION 'Time conflict: you already have a lobby during this time slot';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_time_conflict
    BEFORE INSERT ON lobby_participants
    FOR EACH ROW EXECUTE FUNCTION check_lobby_time_conflict();

CREATE OR REPLACE FUNCTION set_confirmation_deadline()
RETURNS TRIGGER AS $$
BEGIN
    SELECT scheduled_at - INTERVAL '3 hours'
    INTO NEW.must_confirm_by
    FROM lobbies WHERE id = NEW.lobby_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_confirm_deadline
    BEFORE INSERT ON lobby_participants
    FOR EACH ROW EXECUTE FUNCTION set_confirmation_deadline();

CREATE OR REPLACE FUNCTION check_team_elo_balance(p_lobby_id UUID)
RETURNS JSONB AS $$
DECLARE
    lobby_sport sport_type;
    avg_a NUMERIC; avg_b NUMERIC; diff NUMERIC;
BEGIN
    SELECT sport INTO lobby_sport FROM lobbies WHERE id = p_lobby_id;

    SELECT COALESCE(AVG(COALESCE(usr.elo_rating, 1000)), 1000) INTO avg_a
    FROM lobby_participants lp
    LEFT JOIN user_sport_ratings usr ON usr.user_id = lp.user_id AND usr.sport = lobby_sport
    WHERE lp.lobby_id = p_lobby_id AND lp.team = 'A' AND lp.status IN ('joined', 'confirmed');

    SELECT COALESCE(AVG(COALESCE(usr.elo_rating, 1000)), 1000) INTO avg_b
    FROM lobby_participants lp
    LEFT JOIN user_sport_ratings usr ON usr.user_id = lp.user_id AND usr.sport = lobby_sport
    WHERE lp.lobby_id = p_lobby_id AND lp.team = 'B' AND lp.status IN ('joined', 'confirmed');

    diff := ABS(avg_a - avg_b);

    RETURN jsonb_build_object(
        'balanced', diff <= 150,
        'team_a_avg_elo', ROUND(avg_a),
        'team_b_avg_elo', ROUND(avg_b),
        'elo_difference', ROUND(diff)
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_elo(
    p_player_elo INT, p_opponent_elo INT, p_result match_result
) RETURNS INT AS $$
DECLARE
    expected NUMERIC; actual NUMERIC; new_elo INT;
BEGIN
    expected := 1.0 / (1.0 + POWER(10.0, (p_opponent_elo - p_player_elo)::NUMERIC / 400.0));
    CASE p_result
        WHEN 'win'  THEN actual := 1.0;
        WHEN 'loss' THEN actual := 0.0;
        WHEN 'draw' THEN actual := 0.5;
    END CASE;
    new_elo := GREATEST(0, p_player_elo + ROUND(32 * (actual - expected)));
    RETURN new_elo;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION cleanup_old_chat_messages()
RETURNS INT AS $$
DECLARE deleted_count INT;
BEGIN
    DELETE FROM chat_messages cm USING lobbies l
    WHERE cm.lobby_id = l.id
      AND l.status IN ('finished', 'settled', 'cancelled')
      AND l.finished_at < NOW() - INTERVAL '30 days';
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT;
BEGIN
    FOR t IN SELECT unnest(ARRAY[
        'profiles', 'user_sport_ratings', 'fields', 'lobbies',
        'lobby_participants', 'credit_wallets', 'credit_transactions',
        'payments', 'reliability_events', 'chat_messages',
        'matches', 'match_participants'
    ]) LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    END LOOP;
END;
$$;

CREATE POLICY "Profiles viewable by everyone"          ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile"            ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile"            ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Sport ratings viewable by everyone"      ON user_sport_ratings FOR SELECT USING (true);
CREATE POLICY "Fields viewable by everyone"             ON fields FOR SELECT USING (true);

CREATE POLICY "Users can view own wallet"               ON credit_wallets FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own transactions"         ON credit_transactions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Open lobbies visible to all"             ON lobbies FOR SELECT USING (true);
CREATE POLICY "Users can create lobbies"                ON lobbies FOR INSERT WITH CHECK (auth.uid() = host_id);
CREATE POLICY "Host can update own lobby"               ON lobbies FOR UPDATE USING (auth.uid() = host_id);

CREATE POLICY "Participants visible to all"             ON lobby_participants FOR SELECT USING (true);
CREATE POLICY "Users can join lobbies"                  ON lobby_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own participation"      ON lobby_participants FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Chat visible to lobby members" ON chat_messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM lobby_participants lp
            WHERE lp.lobby_id = chat_messages.lobby_id AND lp.user_id = auth.uid())
);
CREATE POLICY "Lobby members can send messages" ON chat_messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND EXISTS (
        SELECT 1 FROM lobby_participants lp
        WHERE lp.lobby_id = chat_messages.lobby_id AND lp.user_id = auth.uid()
          AND lp.status IN ('joined', 'confirmed'))
);

CREATE POLICY "Matches viewable by everyone"            ON matches FOR SELECT USING (true);
CREATE POLICY "Match participants viewable by everyone" ON match_participants FOR SELECT USING (true);

CREATE OR REPLACE VIEW v_leaderboard AS
SELECT
    p.id AS user_id, p.full_name, p.campus, p.avatar_url,
    usr.sport, usr.elo_rating, usr.matches_played, usr.wins, usr.losses,
    CASE WHEN usr.matches_played > 0
         THEN ROUND((usr.wins::NUMERIC / usr.matches_played) * 100, 1)
         ELSE 0 END AS win_rate,
    RANK() OVER (PARTITION BY usr.sport ORDER BY usr.elo_rating DESC) AS sport_rank,
    RANK() OVER (PARTITION BY usr.sport, p.campus ORDER BY usr.elo_rating DESC) AS campus_rank
FROM user_sport_ratings usr
JOIN profiles p ON p.id = usr.user_id;
