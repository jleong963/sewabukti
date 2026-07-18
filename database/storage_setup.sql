-- SewaBukti private evidence bucket (§12.1, NFR-SEC-04/05).
-- Run once in the Supabase SQL editor (or via the CLI).
--
-- The bucket is PRIVATE and only the service role (used by Edge Functions after
-- verifying the Google token + ownership) may read/write it. No policies are
-- created for the anon or authenticated roles, so direct client access is
-- denied by default — Row Level Security on storage.objects is enabled by
-- Supabase and denies anything not explicitly allowed.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'evidence',
  'evidence',
  false,                              -- private
  10485760,                           -- 10 MB ceiling (max PDF, §12.2)
  array[
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/webp',
    'text/plain'
  ]
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Intentionally NO storage.objects policies for anon/authenticated:
-- all access is mediated by Edge Functions using the service role, which
-- bypasses RLS. This keeps evidence objects unreachable by the browser except
-- through short-lived signed URLs issued after an ownership check.
