-- extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- modelssport typedart
CREATE TYPE sport_type AS ENUM (
    'futsal', 'basketball', 'badminton',
    'volleyball', 'tennis', 'tableTennis'
);

-- modelsskill leveldart
CREATE TYPE skill_level AS ENUM (
    'beginner', 'intermediate', 'advanced'
);

-- user entitydart role field
CREATE TYPE user_role AS ENUM (
    'player', 'host', 'admin'
);

-- modelslobby statusdart
CREATE TYPE lobby_status AS ENUM (
    'open', 'confirmed', 'in_progress',
    'finished', 'settled', 'cancelled'
);

-- lobby participant entitydart status field
CREATE TYPE participant_status AS ENUM (
    'joined', 'waitlisted', 'confirmed',
    'removed', 'left', 'no_show'
);

-- modelstransaction typedart
-- values top up deposit hold deposit release deposit forfeit refund
CREATE TYPE transaction_type AS ENUM (
    'top_up', 'deposit_hold', 'deposit_release',
    'deposit_forfeit', 'refund'
);

-- match participant entitydart result field
CREATE TYPE match_result AS ENUM (
    'win', 'loss', 'draw'
);

-- payments future midtrans integration
CREATE TYPE payment_status AS ENUM (
    'pending', 'success', 'failed', 'expired', 'refunded'
);

-- table 1 profiles
-- maps to userentity profileentity
-- used by auth repository impl profile repository impl social repository impl
CREATE TABLE profiles (
    id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email                 TEXT NOT NULL UNIQUE,
    full_name             TEXT,
    nim                   TEXT UNIQUE
                          CONSTRAINT chk_nim_format CHECK (nim ~ '^\d{10}$'),
    campus                TEXT,
    role                  user_role NOT NULL DEFAULT 'player',
    bio                   TEXT DEFAULT '',
    avatar_url            TEXT,
    sport_preferences     TEXT[] DEFAULT '{}',
    skill_levels          JSONB DEFAULT '{}'::JSONB,
    reliability_score     INT NOT NULL DEFAULT 100
                          CHECK (reliability_score BETWEEN 0 AND 100),
    sportsmanship_rating  NUMERIC(3,2) NOT NULL DEFAULT 5.00
                          CHECK (sportsmanship_rating BETWEEN 0 AND 5),
    total_matches_played  INT NOT NULL DEFAULT 0,
    total_wins            INT NOT NULL DEFAULT 0,
    total_losses          INT NOT NULL DEFAULT 0,
    is_onboarded          BOOLEAN NOT NULL DEFAULT FALSE,
    is_suspended          BOOLEAN NOT NULL DEFAULT FALSE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_campus ON profiles(campus);
CREATE INDEX idx_profiles_nim ON profiles(nim);

-- table 2 user sport ratings
-- maps to leaderboard queries match elo updates
-- used by match repository impl leaderboard repository impl
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
CREATE INDEX idx_sport_ratings_user ON user_sport_ratings(user_id);

-- table 3 lobbies
-- maps to lobbyentity
-- used by lobby repository impl
CREATE TABLE lobbies (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    field_id            UUID,
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

-- table 4 lobby participants
-- maps to lobbyparticipantentity
-- used by lobby repository impl
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

-- table 5 credit wallets
-- maps to walletentity
-- used by wallet repository impl
CREATE TABLE credit_wallets (
    user_id     UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    balance     NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    held        NUMERIC(14,2) NOT NULL DEFAULT 0.00 CHECK (held >= 0),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- table 6 credit transactions
-- maps to credittransactionentity
-- used by wallet repository impl
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

-- table 7 payments
-- maps to future midtrans integration
-- stub table not yet used by flutter code but schemaready
CREATE TABLE payments (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id                 UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    midtrans_order_id       TEXT UNIQUE,
    midtrans_transaction_id TEXT,
    amount                  NUMERIC(14,2) NOT NULL,
    status                  payment_status NOT NULL DEFAULT 'pending',
    payment_method          TEXT,
    snap_token              TEXT,
    snap_redirect_url       TEXT,
    raw_response            JSONB,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_user ON payments(user_id, created_at DESC);

-- table 8 reliability events
-- tracks reliability score changes for profiles
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

-- table 9 chat messages
-- maps to chatmessageentity
-- used by chat repository impl with supabase realtime
-- fk alias chat messages sender id fkey used in select join
CREATE TABLE chat_messages (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id    UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    sender_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content     TEXT NOT NULL,
    is_system   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_lobby ON chat_messages(lobby_id, created_at);

-- table 10 matches
-- maps to matchentity
-- used by match repository impl
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

-- table 11 match participants
-- maps to matchparticipantentity
-- used by match repository impl
CREATE TABLE match_participants (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id    UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    team        TEXT CHECK (team IN ('A', 'B')),
    result      match_result,
    elo_before  INT,
    elo_after   INT,
    elo_delta   INT,

    UNIQUE(match_id, user_id)
);

CREATE INDEX idx_match_participants_user ON match_participants(user_id);

-- table 12 notifications
-- maps to notificationentity
-- used by notification repository impl
CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type        TEXT NOT NULL,
    title       TEXT NOT NULL,
    body        TEXT,
    data        JSONB DEFAULT '{}'::JSONB,
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);

-- table 13 friendships
-- maps to friendshipentity
-- used by social repository impl
-- fk aliases used in select join
-- friendships requester id fkey
-- friendships addressee id fkey
CREATE TABLE friendships (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    addressee_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'accepted')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(requester_id, addressee_id),
    CHECK (requester_id != addressee_id)
);

CREATE INDEX idx_friendships_addressee ON friendships(addressee_id, status);
CREATE INDEX idx_friendships_requester ON friendships(requester_id, status);


-- view v sport leaderboard
-- maps to leaderboardentryentity
-- used by leaderboard repository impl
-- columns user id full name campus avatar url sport
-- elo rating matches played wins losses
-- win rate sport rank campus rank
CREATE OR REPLACE VIEW v_sport_leaderboard AS
SELECT
    p.id AS user_id,
    p.full_name,
    p.campus,
    p.avatar_url,
    usr.sport,
    usr.elo_rating,
    usr.matches_played,
    usr.wins,
    usr.losses,
    CASE
        WHEN usr.matches_played > 0
        THEN ROUND((usr.wins::NUMERIC / usr.matches_played) * 100, 1)
        ELSE 0
    END AS win_rate,
    RANK() OVER (
        PARTITION BY usr.sport
        ORDER BY usr.elo_rating DESC
    ) AS sport_rank,
    RANK() OVER (
        PARTITION BY usr.sport, p.campus
        ORDER BY usr.elo_rating DESC
    ) AS campus_rank
FROM user_sport_ratings usr
JOIN profiles p ON p.id = usr.user_id;


-- functions

-- autoupdate updated at on row modification
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- prevent a user from joining overlapping lobbies
CREATE OR REPLACE FUNCTION check_lobby_time_conflict()
RETURNS TRIGGER AS $$
DECLARE
    new_start TIMESTAMPTZ;
    new_end   TIMESTAMPTZ;
BEGIN
    SELECT l.scheduled_at,
           l.scheduled_at + (l.duration_minutes || ' minutes')::INTERVAL
    INTO new_start, new_end
    FROM lobbies l
    WHERE l.id = NEW.lobby_id;

    IF EXISTS (
        SELECT 1
        FROM lobby_participants lp
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

-- autoset confirmation deadline to 3 hours before match
CREATE OR REPLACE FUNCTION set_confirmation_deadline()
RETURNS TRIGGER AS $$
BEGIN
    SELECT l.scheduled_at - INTERVAL '3 hours'
    INTO NEW.must_confirm_by
    FROM lobbies l
    WHERE l.id = NEW.lobby_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- elo calculation function used by match repository impl logic
CREATE OR REPLACE FUNCTION calculate_elo(
    p_player_elo INT,
    p_opponent_elo INT,
    p_result match_result
) RETURNS INT AS $$
DECLARE
    k_factor INT := 32;
    expected NUMERIC;
    actual   NUMERIC;
    new_elo  INT;
BEGIN
    expected := 1.0 / (1.0 + POWER(10.0, (p_opponent_elo - p_player_elo)::NUMERIC / 400.0));

    CASE p_result
        WHEN 'win'  THEN actual := 1.0;
        WHEN 'loss' THEN actual := 0.0;
        WHEN 'draw' THEN actual := 0.5;
    END CASE;

    new_elo := p_player_elo + ROUND(k_factor * (actual - expected));
    IF new_elo < 0 THEN new_elo := 0; END IF;

    RETURN new_elo;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- autocreate profile and wallet on new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
-- 1 create profile
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        new.id,
        new.email,
        new.raw_user_meta_data->>'full_name',
        new.raw_user_meta_data->>'avatar_url'
    );

-- 2 create wallet
    INSERT INTO public.credit_wallets (user_id, balance, held)
    VALUES (new.id, 0.00, 0.00);

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- triggers

-- updated at autoupdate triggers
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT unnest(ARRAY[
            'profiles', 'lobbies', 'lobby_participants',
            'credit_wallets', 'payments', 'user_sport_ratings',
            'friendships'
        ])
    LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_%s_updated_at
             BEFORE UPDATE ON %I
             FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()',
            t, t
        );
    END LOOP;
END;
$$;

-- time conflict check on participant join
CREATE TRIGGER trg_check_time_conflict
    BEFORE INSERT ON lobby_participants
    FOR EACH ROW EXECUTE FUNCTION check_lobby_time_conflict();

-- autoset confirmation deadline on participant join
CREATE TRIGGER trg_set_confirm_deadline
    BEFORE INSERT ON lobby_participants
    FOR EACH ROW EXECUTE FUNCTION set_confirmation_deadline();

-- handle new user signup from authusers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- row level security rls

-- enable rls on all tables
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT unnest(ARRAY[
            'profiles', 'user_sport_ratings', 'lobbies',
            'lobby_participants', 'credit_wallets', 'credit_transactions',
            'payments', 'reliability_events', 'chat_messages',
            'matches', 'match_participants', 'notifications',
            'friendships'
        ])
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    END LOOP;
END;
$$;

-- profiles
CREATE POLICY "profiles_select_all"
    ON profiles FOR SELECT
    USING (true);

CREATE POLICY "profiles_insert_own"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- user sport ratings
CREATE POLICY "sport_ratings_select_all"
    ON user_sport_ratings FOR SELECT
    USING (true);

CREATE POLICY "sport_ratings_insert_own"
    ON user_sport_ratings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "sport_ratings_update_own"
    ON user_sport_ratings FOR UPDATE
    USING (auth.uid() = user_id);

-- lobbies
CREATE POLICY "lobbies_select_all"
    ON lobbies FOR SELECT
    USING (true);

CREATE POLICY "lobbies_insert_own"
    ON lobbies FOR INSERT
    WITH CHECK (auth.uid() = host_id);

-- allows host or participants to update needed for current players increment
CREATE POLICY "lobbies_update_allowed"
    ON lobbies FOR UPDATE
    USING (
        auth.uid() = host_id
        OR EXISTS (
            SELECT 1 FROM lobby_participants lp
            WHERE lp.lobby_id = id AND lp.user_id = auth.uid()
        )
    );

-- lobby participants
CREATE POLICY "participants_select_all"
    ON lobby_participants FOR SELECT
    USING (true);

CREATE POLICY "participants_insert_own"
    ON lobby_participants FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "participants_update_own"
    ON lobby_participants FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "participants_delete_own"
    ON lobby_participants FOR DELETE
    USING (auth.uid() = user_id);

-- credit wallets
CREATE POLICY "wallets_select_own"
    ON credit_wallets FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "wallets_insert_own"
    ON credit_wallets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "wallets_update_own"
    ON credit_wallets FOR UPDATE
    USING (auth.uid() = user_id);

-- credit transactions
CREATE POLICY "transactions_select_own"
    ON credit_transactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "transactions_insert_own"
    ON credit_transactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- payments
CREATE POLICY "payments_select_own"
    ON payments FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "payments_insert_own"
    ON payments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- reliability events
CREATE POLICY "reliability_select_own"
    ON reliability_events FOR SELECT
    USING (auth.uid() = user_id);

-- chat messages
CREATE POLICY "chat_select_lobby_members"
    ON chat_messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM lobby_participants lp
            WHERE lp.lobby_id = chat_messages.lobby_id
              AND lp.user_id = auth.uid()
        )
    );

CREATE POLICY "chat_insert_lobby_members"
    ON chat_messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id
        AND EXISTS (
            SELECT 1 FROM lobby_participants lp
            WHERE lp.lobby_id = chat_messages.lobby_id
              AND lp.user_id = auth.uid()
              AND lp.status IN ('joined', 'confirmed')
        )
    );

-- matches
CREATE POLICY "matches_select_all"
    ON matches FOR SELECT
    USING (true);

CREATE POLICY "matches_insert_authenticated"
    ON matches FOR INSERT
    WITH CHECK (true);

CREATE POLICY "matches_update_authenticated"
    ON matches FOR UPDATE
    USING (true);

-- match participants
CREATE POLICY "match_participants_select_all"
    ON match_participants FOR SELECT
    USING (true);

CREATE POLICY "match_participants_insert_authenticated"
    ON match_participants FOR INSERT
    WITH CHECK (true);

-- notifications
CREATE POLICY "notifications_select_own"
    ON notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "notifications_update_own"
    ON notifications FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "notifications_insert_system"
    ON notifications FOR INSERT
    WITH CHECK (true);

-- friendships
CREATE POLICY "friendships_select_own"
    ON friendships FOR SELECT
    USING (
        auth.uid() = requester_id OR auth.uid() = addressee_id
    );

CREATE POLICY "friendships_insert_own"
    ON friendships FOR INSERT
    WITH CHECK (auth.uid() = requester_id);

CREATE POLICY "friendships_update_own"
    ON friendships FOR UPDATE
    USING (
        auth.uid() = addressee_id OR auth.uid() = requester_id
    );

CREATE POLICY "friendships_delete_own"
    ON friendships FOR DELETE
    USING (
        auth.uid() = requester_id OR auth.uid() = addressee_id
    );


-- realtime
-- enable supabase realtime on tables that use subscriptions
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE lobby_participants;
