# frozen_string_literal: true
module EthonImpersonate
  module Impersonate
    module Tls
      # TLS version are in the format of 0xAABB, where AA is major version and BB is minor
      # version. As of today, the major version is always 03.
      VERSION_MAP = {
        0x0301 => :tlsv1_0,  # TLS 1.0
        0x0302 => :tlsv1_1,  # TLS 1.1
        0x0303 => :tlsv1_2,  # TLS 1.2
        0x0304 => :tlsv1_3,  # TLS 1.3
      }.freeze

      MAX_DEFAULT_VERSION = :tlsv1_3

      # A list of the possible cipher suite ids. Taken from
      # http://www.iana.org/assignments/tls-parameters/tls-parameters.xml
      # via BoringSSL
      CIPHER_NAME_MAP = {
        0x000A => "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
        0x002F => "TLS_RSA_WITH_AES_128_CBC_SHA",
        0x0035 => "TLS_RSA_WITH_AES_256_CBC_SHA",
        0x003C => "TLS_RSA_WITH_AES_128_CBC_SHA256",
        0x003D => "TLS_RSA_WITH_AES_256_CBC_SHA256",
        0x008C => "TLS_PSK_WITH_AES_128_CBC_SHA",
        0x008D => "TLS_PSK_WITH_AES_256_CBC_SHA",
        0x009C => "TLS_RSA_WITH_AES_128_GCM_SHA256",
        0x009D => "TLS_RSA_WITH_AES_256_GCM_SHA384",
        0xC008 => "TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA",
        0xC009 => "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
        0xC00A => "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
        0xC012 => "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA",
        0xC013 => "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
        0xC014 => "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
        0xC023 => "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
        0xC024 => "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384",
        0xC027 => "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
        0xC028 => "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
        0xC02B => "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
        0xC02C => "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
        0xC02F => "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
        0xC030 => "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        0xC035 => "TLS_ECDHE_PSK_WITH_AES_128_CBC_SHA",
        0xC036 => "TLS_ECDHE_PSK_WITH_AES_256_CBC_SHA",
        0xCCA8 => "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
        0xCCA9 => "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
        0xCCAC => "TLS_ECDHE_PSK_WITH_CHACHA20_POLY1305_SHA256",
        0x1301 => "TLS_AES_128_GCM_SHA256",
        0x1302 => "TLS_AES_256_GCM_SHA384",
        0x1303 => "TLS_CHACHA20_POLY1305_SHA256",
      }.freeze

      # RFC tls extensions: https://datatracker.ietf.org/doc/html/rfc6066
      # IANA list: https://www.iana.org/assignments/tls-extensiontype-values/tls-extensiontype-values.xhtml
      EXTENSION_NAME_MAP = {
        0 => "server_name", # default enabled
        1 => "max_fragment_length",
        2 => "client_certificate_url",
        3 => "trusted_ca_keys",
        4 => "truncated_hmac",
        5 => "status_request", # default enabled
        6 => "user_mapping",
        7 => "client_authz",
        8 => "server_authz",
        9 => "cert_type",
        10 => "supported_groups", # default enabled (renamed from "elliptic_curves")
        11 => "ec_point_formats", # default enabled
        12 => "srp",
        13 => "signature_algorithms", # default enabled
        14 => "use_srtp",
        15 => "heartbeat",
        16 => "application_layer_protocol_negotiation", # default enabled
        17 => "status_request_v2",
        18 => "signed_certificate_timestamp",
        19 => "client_certificate_type",
        20 => "server_certificate_type",
        21 => "padding",
        22 => "encrypt_then_mac",
        23 => "extended_master_secret",
        24 => "token_binding",
        25 => "cached_info",
        26 => "tls_lts",
        27 => "compress_certificate",
        28 => "record_size_limit",
        29 => "pwd_protect",
        30 => "pwd_clear",
        31 => "password_salt",
        32 => "ticket_pinning",
        33 => "tls_cert_with_extern_psk",
        34 => "delegated_credential",
        35 => "session_ticket", # default enabled (renamed from "SessionTicket TLS")
        36 => "TLMSP",
        37 => "TLMSP_proxying",
        38 => "TLMSP_delegate",
        39 => "supported_ekt_ciphers",
        # 40 => "Reserved",
        41 => "pre_shared_key",
        42 => "early_data",
        43 => "supported_versions", # default enabled
        44 => "cookie",
        45 => "psk_key_exchange_modes", # default enabled
        # 46 => "Reserved",
        47 => "certificate_authorities",
        48 => "oid_filters",
        49 => "post_handshake_auth",
        50 => "signature_algorithms_cert",
        51 => "key_share", # default enabled
        52 => "transparency_info",
        # 53 => "connection_id", # (deprecated)
        54 => "connection_id",
        55 => "external_id_hash",
        56 => "external_session_id",
        57 => "quic_transport_parameters",
        58 => "ticket_request",
        59 => "dnssec_chain",
        60 => "sequence_number_encryption_algorithms",
        61 => "rrc",
        17513 => "application_settings",  # BoringSSL private usage
        # 62-2569 => "Unassigned",
        # 2570 => "Reserved",
        # 2571-6681 => "Unassigned",
        # 6682 => "Reserved",
        # 6683-10793 => "Unassigned",
        # 10794 => "Reserved",
        # 10795-14905 => "Unassigned",
        # 14906 => "Reserved",
        # 14907-19017 => "Unassigned",
        # 19018 => "Reserved",
        # 19019-23129 => "Unassigned",
        # 23130 => "Reserved",
        # 23131-27241 => "Unassigned",
        # 27242 => "Reserved",
        # 27243-31353 => "Unassigned",
        # 31354 => "Reserved",
        # 31355-35465 => "Unassigned",
        # 35466 => "Reserved",
        # 35467-39577 => "Unassigned",
        # 39578 => "Reserved",
        # 39579-43689 => "Unassigned",
        # 43690 => "Reserved",
        # 43691-47801 => "Unassigned",
        # 47802 => "Reserved",
        # 47803-51913 => "Unassigned",
        # 51914 => "Reserved",
        # 51915-56025 => "Unassigned",
        # 56026 => "Reserved",
        # 56027-60137 => "Unassigned",
        # 60138 => "Reserved",
        # 60139-64249 => "Unassigned",
        # 64250 => "Reserved",
        # 64251-64767 => "Unassigned",
        64768 => "ech_outer_extensions",
        # 64769-65036 => "Unassigned",
        65037 => "encrypted_client_hello",
        # 65038-65279 => "Unassigned",
        # 65280 => "Reserved for Private Use",
        65281 => "renegotiation_info", # default enabled
        # 65282-65535 => "Reserved for Private Use",
      }.freeze

      EXTENSION_ID_MAP = EXTENSION_NAME_MAP.map { |k, v| [v.downcase.to_sym, k] }.to_h

      EXTENSIONS_DEFAULT_ENABLED = [
        :server_name, # 0
        :status_request, # 5
        :signature_algorithms, # 13
        :supported_groups, # 10
        :renegotiation_info, # 65281
        :session_ticket, # 35
        :supported_versions, # 43
        :psk_key_exchange_modes, # 45
        :key_share, # 51
        :ec_point_formats, # 11
        :application_layer_protocol_negotiation, # 16
      ].freeze

      EC_CURVES_MAP = {
        19 => "P-192",
        21 => "P-224",
        23 => "P-256",
        24 => "P-384",
        25 => "P-521",
        29 => "X25519",
        4588 => "X25519MLKEM768",
        25497 => "X25519Kyber768Draft00",
      }.freeze
    end
  end
end
