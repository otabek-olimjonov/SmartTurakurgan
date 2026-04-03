-- Rename rahbariyat category value from 'hokim' to 'rahbariyat'
DO $$
BEGIN
  -- Drop existing check constraint (auto-generated name)
  ALTER TABLE rahbariyat DROP CONSTRAINT IF EXISTS rahbariyat_category_check;

  -- Update existing rows
  UPDATE rahbariyat SET category = 'rahbariyat' WHERE category = 'hokim';

  -- Add new constraint with correct values
  ALTER TABLE rahbariyat ADD CONSTRAINT rahbariyat_category_check
    CHECK (category IN ('rahbariyat', 'apparat', 'deputat', 'kotibiyat'));
END $$;
