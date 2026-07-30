-- XEP-0157 server contact addresses (mod_server_contact_info, core in 13.0).

local domain = os.getenv("DOMAIN")

contact_info = {
	abuse = env_list(os.getenv("SERVER_CONTACT_INFO_ABUSE") or ("xmpp:abuse@" .. domain));
	admin = env_list(os.getenv("SERVER_CONTACT_INFO_ADMIN") or ("xmpp:admin@" .. domain));
	security = env_list(os.getenv("SERVER_CONTACT_INFO_SECURITY") or ("xmpp:security@" .. domain));
	support = env_list(os.getenv("SERVER_CONTACT_INFO_SUPPORT") or ("xmpp:support@" .. domain));
}
