-- ============================================================================
-- EPISODE PROMPTS TABLE - Rotating Prompt Pool
-- ============================================================================
-- This migration creates a prompt pool system for Episode 1 (The Icebreaker)
-- Users will be randomly assigned one of 10 prompts when they start Episode 1
-- The system tracks which prompt was assigned and how often each is used

-- ============================================================================
-- CREATE EPISODE PROMPTS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.episode_prompts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  episode INT NOT NULL CHECK (episode BETWEEN 1 AND 7),
  prompt_text TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  used_count INT DEFAULT 0 NOT NULL
);

-- Index for fetching active prompts efficiently
CREATE INDEX IF NOT EXISTS idx_episode_prompts_episode_active
  ON public.episode_prompts(episode, is_active)
  WHERE is_active = true;

-- ============================================================================
-- ADD PROMPT_ID TO ARTIFACTS TABLE
-- ============================================================================
-- This tracks which prompt was shown to each user for Episode 1

ALTER TABLE public.artifacts
  ADD COLUMN IF NOT EXISTS prompt_id UUID REFERENCES public.episode_prompts(id);

-- ============================================================================
-- INSERT EPISODE 1 PROMPTS (Rotating pool of 10)
-- ============================================================================

INSERT INTO public.episode_prompts (episode, prompt_text) VALUES
(1, 'What''s a harmless habit or quirk of yours that always makes people laugh?'),
(1, 'What''s the most spontaneous thing you''ve ever done?'),
(1, 'What''s a skill you''ve always wanted to learn but haven''t yet?'),
(1, 'What''s your favorite way to spend a rainy day?'),
(1, 'What''s the best piece of advice you''ve ever received?'),
(1, 'What''s a small thing that always makes your day better?'),
(1, 'What''s something you''re irrationally afraid of?'),
(1, 'What''s the most memorable meal you''ve ever had?'),
(1, 'What''s a hidden talent most people don''t know about?'),
(1, 'What''s something you could talk about for hours without getting tired?')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.episode_prompts ENABLE ROW LEVEL SECURITY;

-- Public read access to prompts (all authenticated users can read prompts)
CREATE POLICY "Public read access to episode prompts"
  ON public.episode_prompts FOR SELECT
  TO authenticated
  USING (true);

-- No insert/update/delete policies (only server can modify prompts)

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON public.episode_prompts TO authenticated;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify prompts were created
SELECT
  episode,
  COUNT(*) as prompt_count,
  SUM(used_count) as total_uses
FROM public.episode_prompts
WHERE episode = 1
GROUP BY episode;

-- Expected result: episode=1, prompt_count=10, total_uses=0
