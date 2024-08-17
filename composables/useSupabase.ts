import { createClient } from "@supabase/supabase-js";

const SUPABASE_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5tbnVwd2p4emlua3l5eHZqeXBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM3MzM5ODcsImV4cCI6MjAzOTMwOTk4N30.17LGqo3Zq9OuFRH_WlBCZmNBNtRB_gFvv-MkDmrWc1s";
const SUPABASE_URL = "https://nmnupwjxzinkyyxvjypg.supabase.co";

const useSupabase = () => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

  return {
    supabase,
  };
};

export default useSupabase;
