-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text NOT NULL UNIQUE,
  full_name text,
  nim text UNIQUE CHECK (nim ~ '^\d{10}$'::text),
  campus text,
  role USER-DEFINED NOT NULL DEFAULT 'player'::user_role,
  bio text DEFAULT ''::text,
  avatar_url text,
  sport_preferences ARRAY DEFAULT '{}'::text[],
  skill_levels jsonb DEFAULT '{}'::jsonb,
  reliability_score integer NOT NULL DEFAULT 100 CHECK (reliability_score >= 0 AND reliability_score <= 100),
  sportsmanship_rating numeric NOT NULL DEFAULT 5.00 CHECK (sportsmanship_rating >= 0::numeric AND sportsmanship_rating <= 5::numeric),
  total_matches_played integer NOT NULL DEFAULT 0,
  total_wins integer NOT NULL DEFAULT 0,
  total_losses integer NOT NULL DEFAULT 0,
  is_onboarded boolean NOT NULL DEFAULT false,
  is_suspended boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_sport_ratings (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  sport USER-DEFINED NOT NULL,
  elo_rating integer NOT NULL DEFAULT 1000,
  matches_played integer NOT NULL DEFAULT 0,
  wins integer NOT NULL DEFAULT 0,
  losses integer NOT NULL DEFAULT 0,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_sport_ratings_pkey PRIMARY KEY (id),
  CONSTRAINT user_sport_ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.lobbies (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  host_id uuid NOT NULL,
  field_id uuid,
  title text NOT NULL,
  sport USER-DEFINED NOT NULL,
  description text DEFAULT ''::text,
  scheduled_at timestamp with time zone NOT NULL,
  duration_minutes integer NOT NULL DEFAULT 60,
  min_players integer NOT NULL DEFAULT 2,
  max_players integer NOT NULL DEFAULT 10,
  current_players integer NOT NULL DEFAULT 0,
  min_elo integer,
  max_elo integer,
  deposit_amount numeric NOT NULL DEFAULT 0,
  host_deposit_amount numeric,
  status USER-DEFINED NOT NULL DEFAULT 'open'::lobby_status,
  latitude double precision,
  longitude double precision,
  confirmed_at timestamp with time zone,
  finished_at timestamp with time zone,
  settled_at timestamp with time zone,
  cancelled_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT lobbies_pkey PRIMARY KEY (id),
  CONSTRAINT lobbies_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.lobby_participants (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  lobby_id uuid NOT NULL,
  user_id uuid NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'joined'::participant_status,
  team text CHECK (team = ANY (ARRAY['A'::text, 'B'::text])),
  position integer,
  deposit_held boolean NOT NULL DEFAULT false,
  confirmed_at timestamp with time zone,
  must_confirm_by timestamp with time zone,
  joined_at timestamp with time zone NOT NULL DEFAULT now(),
  left_at timestamp with time zone,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT lobby_participants_pkey PRIMARY KEY (id),
  CONSTRAINT lobby_participants_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id),
  CONSTRAINT lobby_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.credit_wallets (
  user_id uuid NOT NULL,
  balance numeric NOT NULL DEFAULT 0.00 CHECK (balance >= 0::numeric),
  held numeric NOT NULL DEFAULT 0.00 CHECK (held >= 0::numeric),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT credit_wallets_pkey PRIMARY KEY (user_id),
  CONSTRAINT credit_wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.credit_transactions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  type USER-DEFINED NOT NULL,
  amount numeric NOT NULL,
  balance_after numeric,
  reference_id uuid,
  description text DEFAULT ''::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT credit_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT credit_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  midtrans_order_id text UNIQUE,
  midtrans_transaction_id text,
  amount numeric NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::payment_status,
  payment_method text,
  snap_token text,
  snap_redirect_url text,
  raw_response jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.reliability_events (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  lobby_id uuid,
  event_type text NOT NULL,
  score_delta integer NOT NULL DEFAULT 0,
  description text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT reliability_events_pkey PRIMARY KEY (id),
  CONSTRAINT reliability_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT reliability_events_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id)
);
CREATE TABLE public.chat_messages (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  lobby_id uuid NOT NULL,
  sender_id uuid NOT NULL,
  content text NOT NULL,
  is_system boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT chat_messages_pkey PRIMARY KEY (id),
  CONSTRAINT chat_messages_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id),
  CONSTRAINT chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.matches (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  lobby_id uuid NOT NULL,
  sport USER-DEFINED NOT NULL,
  played_at timestamp with time zone NOT NULL,
  duration_minutes integer,
  team_a_score integer,
  team_b_score integer,
  elo_changes jsonb DEFAULT '{}'::jsonb,
  settled boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT matches_pkey PRIMARY KEY (id),
  CONSTRAINT matches_lobby_id_fkey FOREIGN KEY (lobby_id) REFERENCES public.lobbies(id)
);
CREATE TABLE public.match_participants (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  match_id uuid NOT NULL,
  user_id uuid NOT NULL,
  team text CHECK (team = ANY (ARRAY['A'::text, 'B'::text])),
  result USER-DEFINED,
  elo_before integer,
  elo_after integer,
  elo_delta integer,
  CONSTRAINT match_participants_pkey PRIMARY KEY (id),
  CONSTRAINT match_participants_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id),
  CONSTRAINT match_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  type text NOT NULL,
  title text NOT NULL,
  body text,
  data jsonb DEFAULT '{}'::jsonb,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.friendships (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  requester_id uuid NOT NULL,
  addressee_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT friendships_pkey PRIMARY KEY (id),
  CONSTRAINT friendships_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.profiles(id),
  CONSTRAINT friendships_addressee_id_fkey FOREIGN KEY (addressee_id) REFERENCES public.profiles(id)
);
