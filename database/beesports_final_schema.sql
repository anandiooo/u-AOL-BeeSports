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

CREATE TYPE lobby_visibility AS ENUM (
    'public', 'private'
);

CREATE TYPE participant_status AS ENUM (
    'joined', 'waitlisted', 'confirmed', 'removed', 'left', 'no_show'
);

CREATE TYPE transaction_type AS ENUM (
    'top_up', 'deposit_hold', 'deposit_release', 'deposit_forfeit',
    'refund', 'payout', 'service_fee'
);

CREATE TYPE payment_status AS ENUM (
    'pending', 'success', 'failed', 'expired', 'refunded'
);

CREATE TYPE report_status AS ENUM (
    'pending', 'reviewed', 'resolved', 'dismissed'
);

CREATE TYPE report_category AS ENUM (
    'toxic_chat', 'no_show', 'cheating', 'harassment', 'spam', 'other'
);

CREATE TYPE friend_status AS ENUM (
    'pending', 'accepted', 'declined', 'blocked'
);

CREATE TYPE suspension_status AS ENUM (
    'active', 'expired', 'revoked'
);

CREATE TYPE match_result AS ENUM (
    'win', 'loss', 'draw'
);

CREATE TABLE profiles (
    id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email           TEXT NOT NULL UNIQUE,
    full_name       TEXT,
    nim             TEXT UNIQUE
                    CONSTRAINT chk_nim_format CHECK (nim ~ '^\d{10}$'),
    campus          TEXT,
    role            user_role NOT NULL DEFAULT 'player',
    bio             TEXT DEFAULT '',
    avatar_url      TEXT,
    sport_preferences TEXT[] DEFAULT '{}',
    skill_levels      JSONB DEFAULT '{}'::JSONB,
    reliability_score   INT NOT NULL DEFAULT 100 CHECK (reliability_score BETWEEN 0 AND 100),
    sportsmanship_rating NUMERIC(3,2) NOT NULL DEFAULT 5.00 CHECK (sportsmanship_rating BETWEEN 0 AND 5),
    total_matches_played INT NOT NULL DEFAULT 0,
    total_wins           INT NOT NULL DEFAULT 0,
    total_losses         INT NOT NULL DEFAULT 0,
    xp              INT NOT NULL DEFAULT 0,
    level           INT NOT NULL DEFAULT 1,
    is_onboarded    BOOLEAN NOT NULL DEFAULT FALSE,
    is_suspended    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
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
    season          INT NOT NULL DEFAULT 1,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, sport, season)
);

CREATE INDEX idx_sport_ratings_sport ON user_sport_ratings(sport, elo_rating DESC);
CREATE INDEX idx_sport_ratings_user ON user_sport_ratings(user_id);

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
    google_photos   TEXT[] DEFAULT '{}',
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    last_synced_at  TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fields_location ON fields USING GIST (
    point(longitude, latitude)
);
CREATE INDEX idx_fields_sport ON fields USING GIN (sport_types);
CREATE INDEX idx_fields_google ON fields(google_place_id);

CREATE TABLE lobbies (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id             UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    field_id            UUID REFERENCES fields(id),
    title               TEXT NOT NULL,
    sport               sport_type NOT NULL,
    description         TEXT DEFAULT '',
    visibility          lobby_visibility NOT NULL DEFAULT 'public',
    scheduled_at        TIMESTAMPTZ NOT NULL,
    duration_minutes    INT NOT NULL DEFAULT 60,
    min_players         INT NOT NULL DEFAULT 2,
    max_players         INT NOT NULL DEFAULT 10,
    current_players     INT NOT NULL DEFAULT 0,
    min_elo             INT,
    max_elo             INT,
    skill_range         skill_level,
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
CREATE INDEX idx_lobbies_location ON lobbies USING GIST (
    point(longitude, latitude)
) WHERE longitude IS NOT NULL AND latitude IS NOT NULL;

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

CREATE TABLE lobby_invitations (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id    UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    inviter_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    invitee_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    accepted    BOOLEAN,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    responded_at TIMESTAMPTZ,

    UNIQUE(lobby_id, invitee_id)
);

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
CREATE INDEX idx_transactions_type ON credit_transactions(type);

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
CREATE INDEX idx_payments_midtrans ON payments(midtrans_order_id);

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

CREATE TABLE suspensions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reason          TEXT NOT NULL,
    status          suspension_status NOT NULL DEFAULT 'active',
    starts_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ends_at         TIMESTAMPTZ,
    issued_by       UUID REFERENCES profiles(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_suspensions_user ON suspensions(user_id, status);

CREATE TABLE user_favorite_fields (
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    field_id    UUID NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, field_id)
);

CREATE TABLE chat_messages (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id    UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    sender_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content     TEXT NOT NULL,
    is_system   BOOLEAN NOT NULL DEFAULT FALSE,
    is_flagged  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_lobby ON chat_messages(lobby_id, created_at);
CREATE INDEX idx_chat_cleanup ON chat_messages(created_at);

CREATE TABLE matches (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lobby_id        UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    sport           sport_type NOT NULL,
    played_at       TIMESTAMPTZ NOT NULL,
    duration_minutes INT,
    team_a_score    INT,
    team_b_score    INT,
    elo_changes     JSONB DEFAULT '{}'::JSONB,
    elo_balanced    BOOLEAN NOT NULL DEFAULT TRUE,
    settled         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_matches_lobby ON matches(lobby_id);
CREATE INDEX idx_matches_sport ON matches(sport);

CREATE TABLE match_participants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    team            TEXT CHECK (team IN ('A', 'B')),
    result          match_result,
    elo_before      INT,
    elo_after       INT,
    elo_delta       INT,
    is_mvp          BOOLEAN NOT NULL DEFAULT FALSE,
    sportsmanship_received NUMERIC(3,2),

    UNIQUE(match_id, user_id)
);

CREATE INDEX idx_match_participants_user ON match_participants(user_id);

CREATE TABLE mvp_votes (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id    UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    voter_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    nominee_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(match_id, voter_id)
);

CREATE TABLE sportsmanship_ratings (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id    UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    rater_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rated_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    score       NUMERIC(3,2) NOT NULL CHECK (score BETWEEN 1 AND 5),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(match_id, rater_id, rated_id)
);

CREATE TABLE badges (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code        TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_url    TEXT,
    category    TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_badges (
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    badge_id    UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, badge_id)
);

CREATE TABLE seasons (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    starts_at   TIMESTAMPTZ NOT NULL,
    ends_at     TIMESTAMPTZ NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE follows (
    follower_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id != following_id)
);

CREATE INDEX idx_follows_following ON follows(following_id);

CREATE TABLE friendships (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    addressee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status      friend_status NOT NULL DEFAULT 'pending',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(requester_id, addressee_id),
    CHECK (requester_id != addressee_id)
);

CREATE INDEX idx_friendships_addressee ON friendships(addressee_id, status);

CREATE TABLE missions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           TEXT NOT NULL,
    description     TEXT NOT NULL,
    xp_reward       INT NOT NULL DEFAULT 0,
    target_count    INT NOT NULL DEFAULT 1,
    mission_type    TEXT NOT NULL,
    sport_filter    sport_type,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    week_start      DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_missions (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    mission_id  UUID NOT NULL REFERENCES missions(id) ON DELETE CASCADE,
    progress    INT NOT NULL DEFAULT 0,
    completed   BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, mission_id)
);

CREATE TABLE clans (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL UNIQUE,
    tag             TEXT NOT NULL UNIQUE,
    description     TEXT DEFAULT '',
    logo_url        TEXT,
    leader_id       UUID NOT NULL REFERENCES profiles(id),
    elo_rating      INT NOT NULL DEFAULT 1000,
    member_count    INT NOT NULL DEFAULT 1,
    max_members     INT NOT NULL DEFAULT 30,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE clan_members (
    clan_id     UUID NOT NULL REFERENCES clans(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role        TEXT NOT NULL DEFAULT 'member',
    joined_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (clan_id, user_id)
);

CREATE INDEX idx_clan_members_user ON clan_members(user_id);

CREATE TABLE tournaments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL,
    sport           sport_type NOT NULL,
    description     TEXT DEFAULT '',
    max_teams       INT NOT NULL DEFAULT 8,
    prize_pool      NUMERIC(14,2) DEFAULT 0,
    status          TEXT NOT NULL DEFAULT 'registration',
    starts_at       TIMESTAMPTZ,
    ends_at         TIMESTAMPTZ,
    created_by      UUID NOT NULL REFERENCES profiles(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE tournament_teams (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id   UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    clan_id         UUID REFERENCES clans(id),
    name            TEXT NOT NULL,
    seed            INT,
    eliminated      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE tournament_brackets (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id   UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    round           INT NOT NULL,
    match_order     INT NOT NULL,
    team_a_id       UUID REFERENCES tournament_teams(id),
    team_b_id       UUID REFERENCES tournament_teams(id),
    winner_id       UUID REFERENCES tournament_teams(id),
    score_a         INT,
    score_b         INT,
    played_at       TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE reports (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reported_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    lobby_id        UUID REFERENCES lobbies(id),
    match_id        UUID REFERENCES matches(id),
    category        report_category NOT NULL,
    description     TEXT NOT NULL,
    evidence_urls   TEXT[] DEFAULT '{}',
    status          report_status NOT NULL DEFAULT 'pending',
    reviewed_by     UUID REFERENCES profiles(id),
    reviewed_at     TIMESTAMPTZ,
    resolution_note TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reports_status ON reports(status, created_at DESC);
CREATE INDEX idx_reports_reported ON reports(reported_id);

CREATE TABLE admin_audit_log (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id    UUID NOT NULL REFERENCES profiles(id),
    action      TEXT NOT NULL,
    target_type TEXT,
    target_id   UUID,
    details     JSONB DEFAULT '{}'::JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_admin ON admin_audit_log(admin_id, created_at DESC);

CREATE TABLE lobby_recommendations (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    lobby_id    UUID NOT NULL REFERENCES lobbies(id) ON DELETE CASCADE,
    score       NUMERIC(8,4) NOT NULL,
    factors     JSONB DEFAULT '{}'::JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, lobby_id)
);

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

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT unnest(ARRAY[
            'profiles', 'fields', 'lobbies', 'lobby_participants',
            'credit_wallets', 'payments', 'friendships',
            'clans', 'tournaments', 'user_sport_ratings'
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
        RAISE EXCEPTION 'Time conflict: you are already in a lobby during this time slot';
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
    SELECT l.scheduled_at - INTERVAL '3 hours'
    INTO NEW.must_confirm_by
    FROM lobbies l
    WHERE l.id = NEW.lobby_id;

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
    avg_a NUMERIC;
    avg_b NUMERIC;
    diff  NUMERIC;
    threshold NUMERIC := 150;
BEGIN
    SELECT sport INTO lobby_sport FROM lobbies WHERE id = p_lobby_id;

    SELECT COALESCE(AVG(COALESCE(usr.elo_rating, 1000)), 1000)
    INTO avg_a
    FROM lobby_participants lp
    LEFT JOIN user_sport_ratings usr ON usr.user_id = lp.user_id AND usr.sport = lobby_sport
    WHERE lp.lobby_id = p_lobby_id AND lp.team = 'A' AND lp.status IN ('joined', 'confirmed');

    SELECT COALESCE(AVG(COALESCE(usr.elo_rating, 1000)), 1000)
    INTO avg_b
    FROM lobby_participants lp
    LEFT JOIN user_sport_ratings usr ON usr.user_id = lp.user_id AND usr.sport = lobby_sport
    WHERE lp.lobby_id = p_lobby_id AND lp.team = 'B' AND lp.status IN ('joined', 'confirmed');

    diff := ABS(avg_a - avg_b);

    RETURN jsonb_build_object(
        'balanced', diff <= threshold,
        'team_a_avg_elo', ROUND(avg_a),
        'team_b_avg_elo', ROUND(avg_b),
        'elo_difference', ROUND(diff),
        'threshold', threshold
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_elo(
    p_player_elo INT,
    p_opponent_elo INT,
    p_result match_result
) RETURNS INT AS $$
DECLARE
    k_factor     INT := 32;
    expected     NUMERIC;
    actual       NUMERIC;
    new_elo      INT;
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

CREATE OR REPLACE FUNCTION cleanup_old_chat_messages()
RETURNS INT AS $$
DECLARE
    deleted_count INT;
BEGIN
    DELETE FROM chat_messages cm
    USING lobbies l
    WHERE cm.lobby_id = l.id
      AND l.status IN ('finished', 'settled', 'cancelled')
      AND l.finished_at IS NOT NULL
      AND l.finished_at < NOW() - INTERVAL '30 days';

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT unnest(ARRAY[
            'profiles', 'user_sport_ratings', 'fields', 'lobbies',
            'lobby_participants', 'lobby_invitations', 'credit_wallets',
            'credit_transactions', 'payments', 'reliability_events',
            'suspensions', 'user_favorite_fields', 'chat_messages',
            'matches', 'match_participants', 'mvp_votes',
            'sportsmanship_ratings', 'badges', 'user_badges', 'seasons',
            'follows', 'friendships', 'missions', 'user_missions',
            'clans', 'clan_members', 'tournaments', 'tournament_teams',
            'tournament_brackets', 'reports', 'admin_audit_log',
            'lobby_recommendations', 'notifications'
        ])
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    END LOOP;
END;
$$;

CREATE POLICY "Profiles are viewable by everyone"
    ON profiles FOR SELECT USING (true);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Sport ratings are viewable by everyone"
    ON user_sport_ratings FOR SELECT USING (true);

CREATE POLICY "Fields are viewable by everyone"
    ON fields FOR SELECT USING (true);

CREATE POLICY "Users can view own wallet"
    ON credit_wallets FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System manages wallets"
    ON credit_wallets FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own transactions"
    ON credit_transactions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Public lobbies visible to all"
    ON lobbies FOR SELECT USING (visibility = 'public' OR host_id = auth.uid());

CREATE POLICY "Authenticated users can create lobbies"
    ON lobbies FOR INSERT WITH CHECK (auth.uid() = host_id);

CREATE POLICY "Host can update own lobby"
    ON lobbies FOR UPDATE USING (auth.uid() = host_id);

CREATE POLICY "Participants visible to lobby members"
    ON lobby_participants FOR SELECT USING (true);

CREATE POLICY "Users can join lobbies"
    ON lobby_participants FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own participation"
    ON lobby_participants FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Chat visible to lobby participants"
    ON chat_messages FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM lobby_participants lp
            WHERE lp.lobby_id = chat_messages.lobby_id
              AND lp.user_id = auth.uid()
        )
    );

CREATE POLICY "Lobby members can send messages"
    ON chat_messages FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM lobby_participants lp
            WHERE lp.lobby_id = chat_messages.lobby_id
              AND lp.user_id = auth.uid()
              AND lp.status IN ('joined', 'confirmed')
        )
    );

CREATE POLICY "Users can view own notifications"
    ON notifications FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
    ON notifications FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Follows are publicly visible"
    ON follows FOR SELECT USING (true);

CREATE POLICY "Users can manage own follows"
    ON follows FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can unfollow"
    ON follows FOR DELETE USING (auth.uid() = follower_id);

CREATE POLICY "Users can view own friendships"
    ON friendships FOR SELECT USING (
        auth.uid() = requester_id OR auth.uid() = addressee_id
    );

CREATE POLICY "Users can send friend requests"
    ON friendships FOR INSERT WITH CHECK (auth.uid() = requester_id);

CREATE POLICY "Users can respond to friend requests"
    ON friendships FOR UPDATE USING (
        auth.uid() = addressee_id OR auth.uid() = requester_id
    );

CREATE POLICY "Matches are viewable by everyone"
    ON matches FOR SELECT USING (true);

CREATE POLICY "Match participants are viewable by everyone"
    ON match_participants FOR SELECT USING (true);

CREATE POLICY "Badges are viewable by everyone"
    ON badges FOR SELECT USING (true);

CREATE POLICY "User badges are viewable by everyone"
    ON user_badges FOR SELECT USING (true);

CREATE POLICY "Seasons are viewable by everyone"
    ON seasons FOR SELECT USING (true);

CREATE POLICY "Clans are viewable by everyone"
    ON clans FOR SELECT USING (true);

CREATE POLICY "Clan members are viewable by everyone"
    ON clan_members FOR SELECT USING (true);

CREATE OR REPLACE VIEW v_sport_leaderboard AS
SELECT
    usr.id AS user_id,
    p.full_name,
    p.campus,
    p.avatar_url,
    usr.sport,
    usr.elo_rating,
    usr.matches_played,
    usr.wins,
    usr.losses,
    CASE WHEN usr.matches_played > 0
         THEN ROUND((usr.wins::NUMERIC / usr.matches_played) * 100, 1)
         ELSE 0
    END AS win_rate,
    RANK() OVER (PARTITION BY usr.sport ORDER BY usr.elo_rating DESC) AS sport_rank,
    RANK() OVER (PARTITION BY usr.sport, p.campus ORDER BY usr.elo_rating DESC) AS campus_rank
FROM user_sport_ratings usr
JOIN profiles p ON p.id = usr.user_id
WHERE usr.season = (SELECT id FROM seasons WHERE is_active = TRUE LIMIT 1);

INSERT INTO badges (code, name, description, category) VALUES
    ('first_match',     'First Match',       'Played your first match',            'match'),
    ('win_streak_3',    'Hat Trick',         'Won 3 matches in a row',             'match'),
    ('win_streak_5',    'Unstoppable',       'Won 5 matches in a row',             'match'),
    ('mvp_1',           'Rising Star',       'Received your first MVP award',      'match'),
    ('mvp_5',           'Star Player',       'Received 5 MVP awards',              'match'),
    ('matches_10',      'Regular',           'Played 10 matches',                  'loyalty'),
    ('matches_50',      'Veteran',           'Played 50 matches',                  'loyalty'),
    ('matches_100',     'Legend',            'Played 100 matches',                 'loyalty'),
    ('reliability_100', 'Reliable Player',   'Maintained 100% reliability score',  'loyalty'),
    ('host_5',          'Community Builder', 'Hosted 5 lobbies',                   'social'),
    ('friends_10',      'Social Bee',        'Made 10 friends',                    'social'),
    ('multi_sport',     'All-Rounder',       'Played 3 different sports',          'match')
ON CONFLICT (code) DO NOTHING;

INSERT INTO seasons (name, starts_at, ends_at, is_active) VALUES
    ('Season 1', '2026-03-01T00:00:00Z', '2026-06-01T00:00:00Z', TRUE);
