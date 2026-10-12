/// DB-level guards for the append-only ledger (S1-02).
///
/// - No deletes on `txn`, `ledger_entry`, `audit_log`.
/// - `ledger_entry` and `audit_log` rows are never updated.
/// - `txn` is immutable except status/void fields, `day_close_id`, `shift_id`.
///   An "edit" is a new txn that replaces the old one.
/// - Transactions of a closed day cannot change or gain entries until the
///   day is reopened.
const integrityTriggerStatements = <String>[
  '''
CREATE TRIGGER trg_txn_no_delete BEFORE DELETE ON txn
BEGIN SELECT RAISE(ABORT, 'txn rows cannot be deleted'); END''',
  '''
CREATE TRIGGER trg_le_no_delete BEFORE DELETE ON ledger_entry
BEGIN SELECT RAISE(ABORT, 'ledger_entry rows cannot be deleted'); END''',
  '''
CREATE TRIGGER trg_audit_no_delete BEFORE DELETE ON audit_log
BEGIN SELECT RAISE(ABORT, 'audit_log rows cannot be deleted'); END''',
  '''
CREATE TRIGGER trg_le_no_update BEFORE UPDATE ON ledger_entry
BEGIN SELECT RAISE(ABORT, 'ledger_entry rows are immutable'); END''',
  '''
CREATE TRIGGER trg_audit_no_update BEFORE UPDATE ON audit_log
BEGIN SELECT RAISE(ABORT, 'audit_log rows are immutable'); END''',
  '''
CREATE TRIGGER trg_txn_immutable BEFORE UPDATE ON txn
WHEN NEW.id IS NOT OLD.id
  OR NEW.type IS NOT OLD.type
  OR NEW.occurred_at IS NOT OLD.occurred_at
  OR NEW.recorded_at IS NOT OLD.recorded_at
  OR NEW.amount_paisa IS NOT OLD.amount_paisa
  OR NEW.charge_paisa IS NOT OLD.charge_paisa
  OR NEW.commission_paisa IS NOT OLD.commission_paisa
  OR NEW.commission_rule_id IS NOT OLD.commission_rule_id
  OR NEW.commission_overridden IS NOT OLD.commission_overridden
  OR NEW.customer_id IS NOT OLD.customer_id
  OR NEW.customer_number IS NOT OLD.customer_number
  OR NEW.reference IS NOT OLD.reference
  OR NEW.note IS NOT OLD.note
  OR NEW.replaces_txn_id IS NOT OLD.replaces_txn_id
  OR NEW.created_by IS NOT OLD.created_by
  OR NEW.device_id IS NOT OLD.device_id
BEGIN SELECT RAISE(ABORT, 'txn column is immutable'); END''',
  '''
CREATE TRIGGER trg_txn_locked BEFORE UPDATE ON txn
WHEN OLD.day_close_id IS NOT NULL
  AND NEW.day_close_id IS OLD.day_close_id
  AND (SELECT status FROM day_close WHERE id = OLD.day_close_id) <> 'reopened'
BEGIN SELECT RAISE(ABORT, 'transaction belongs to a closed day'); END''',
  '''
CREATE TRIGGER trg_le_locked BEFORE INSERT ON ledger_entry
WHEN (SELECT day_close_id FROM txn WHERE id = NEW.txn_id) IS NOT NULL
  AND (SELECT dc.status FROM day_close dc
       JOIN txn t ON t.day_close_id = dc.id
       WHERE t.id = NEW.txn_id) <> 'reopened'
BEGIN SELECT RAISE(ABORT, 'transaction belongs to a closed day'); END''',
];
