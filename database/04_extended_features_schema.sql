-- BeeSports Extended Schema: Achievements, Missions, XP/Leveling, Private Lobbies
-- WARNING: This schema is for context only and is not meant to be run without review.

-- ── XP & Leveling (additions to profiles) ────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS xp integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS level integer NOT NULL DEFAULT 1;

-- ── Achievements ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.achievements (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  key text NOT NULL UNIQUE,
  title text NOT NULL,
  description text DEFAULT '',
  icon text DEFAULT '🏆',
  tier text NOT NULL DEFAULT 'bronze' CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum')),
  xp_reward integer NOT NULL DEFAULT 100,
  required_count integer,
  category text NOT NULL DEFAULT 'general',
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT achievements_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.user_achievements (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  achievement_id uuid NOT NULL,
  progress integer NOT NULL DEFAULT 0,
  is_unlocked boolean NOT NULL DEFAULT false,
  unlocked_at timestamp with time zone,
  CONSTRAINT user_achievements_pkey PRIMARY KEY (id),
  CONSTRAINT user_achievements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_achievements_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(id),
  CONSTRAINT user_achievements_unique UNIQUE (user_id, achievement_id)
);

-- ── Weekly Missions ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.missions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  description text DEFAULT '',
  type text NOT NULL, -- 'play_matches', 'win_matches', 'join_lobbies', 'host_lobbies'
  target_count integer NOT NULL DEFAULT 1,
  xp_reward integer NOT NULL DEFAULT 50,
  starts_at timestamp with time zone NOT NULL,
  expires_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT missions_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.user_missions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  mission_id uuid NOT NULL,
  current_progress integer NOT NULL DEFAULT 0,
  is_completed boolean NOT NULL DEFAULT false,
  is_reward_claimed boolean NOT NULL DEFAULT false,
  CONSTRAINT user_missions_pkey PRIMARY KEY (id),
  CONSTRAINT user_missions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_missions_mission_id_fkey FOREIGN KEY (mission_id) REFERENCES public.missions(id),
  CONSTRAINT user_missions_unique UNIQUE (user_id, mission_id)
);

-- ── Private Lobbies ──────────────────────────────────────────────
ALTER TABLE public.lobbies
  ADD COLUMN IF NOT EXISTS is_private boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS invite_code text UNIQUE;

-- ── Lobby Invitations ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.lobby_invitations (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  lobby_id uuid NOT NULL,
  inviter_id uuid NOT NULL,
  invitee_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT lobby_invitations_pkey PRIMARY KEY (id),
  CONSTRAINT lobby_invitations_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id),
  CONSTRAINT lobby_invitations_inviter_id_fkey FOREIGN KEY (inviter_id) REFERENCES public.profiles(id),
  CONSTRAINT lobby_invitations_invitee_id_fkey FOREIGN KEY (invitee_id) REFERENCES public.profiles(id)
);

-- ── Chat Reports (Toxicity) ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_reports (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  message_id uuid NOT NULL,
  reporter_id uuid NOT NULL,
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'action_taken')),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT chat_reports_pkey PRIMARY KEY (id),
  CONSTRAINT chat_reports_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.chat_messages(id),
  CONSTRAINT chat_reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id)
);

-- ── Seed achievements ────────────────────────────────────────────
INSERT INTO public.achievements (key, title, description, icon, tier, xp_reward, required_count, category) VALUES
  ('first_match', 'First Match', 'Play your first match', 'sports_soccer', 'bronze', 100, 1, 'matches'),
  ('match_5', 'Regular Player', 'Play 5 matches', 'military_tech', 'bronze', 200, 5, 'matches'),
  ('match_25', 'Seasoned Athlete', 'Play 25 matches', 'workspace_premium', 'silver', 500, 25, 'matches'),
  ('match_100', 'Century Club', 'Play 100 matches', 'emoji_events', 'gold', 1000, 100, 'matches'),
  ('win_first', 'First Victory', 'Win your first match', 'star', 'bronze', 150, 1, 'wins'),
  ('win_10', 'Winning Streak', 'Win 10 matches', 'local_fire_department', 'silver', 400, 10, 'wins'),
  ('win_50', 'Champion', 'Win 50 matches', 'workspace_premium', 'gold', 800, 50, 'wins'),
  ('host_first', 'Host Debut', 'Host your first lobby', 'campaign', 'bronze', 100, 1, 'hosting'),
  ('host_10', 'Community Builder', 'Host 10 lobbies', 'groups', 'silver', 300, 10, 'hosting'),
  ('reliable_100', 'Dependable', 'Maintain 100 reliability score for 10 matches', 'verified', 'gold', 500, 10, 'reliability'),
  ('social_5', 'Socialite', 'Add 5 friends', 'group_add', 'bronze', 150, 5, 'social'),
  ('multi_sport', 'All-Rounder', 'Play 3 different sports', 'category', 'silver', 300, 3, 'variety')
ON CONFLICT (key) DO NOTHING;
