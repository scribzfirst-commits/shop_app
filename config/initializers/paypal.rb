paypal_config = Rails.application.config_for(:paypal)

PayPal::SDK.configure(
mode: paypal_config["mode"],               # "sandbox" or "live"
client_id: paypal_config["client_id"],    # REST API client_id
client_secret: paypal_config["client_secret"], # REST API client_secret
username: paypal_config["username"],      # Classic API username
password: paypal_config["password"],      # Classic API password
signature: paypal_config["signature"],    # Classic API signature
app_id: paypal_config["app_id"],          # Classic API app_id
ssl_options: {ca_file: "/etc/ssl/certs/ca-certificates.crt"  
}
)
