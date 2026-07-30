-- End-to-end encryption policy (mod_e2e_policy, community).
-- Operator decision: OPTIONAL — nudge clients toward OMEMO/OTR/PGP without
-- blocking plaintext, for best usability across mixed clients.
-- (Call media is separately encrypted with DTLS-SRTP regardless of this.)

e2e_policy_chat = os.getenv("E2E_POLICY_CHAT") or "optional"
e2e_policy_muc = os.getenv("E2E_POLICY_MUC") or "optional"

e2e_policy_whitelist = env_list(os.getenv("E2E_POLICY_WHITELIST"))

e2e_policy_message_optional_chat = "For your privacy, OMEMO, OTR or PGP encryption is strongly recommended for conversations on this server."
e2e_policy_message_required_chat = "For security reasons, encryption (OMEMO/OTR/PGP) is required for conversations on this server."
e2e_policy_message_optional_muc = "For your privacy, OMEMO, OTR or PGP encryption is strongly recommended in this room."
e2e_policy_message_required_muc = "For security reasons, encryption (OMEMO/OTR/PGP) is required in this room."
