#
## Etherpad-Lite support
#
# @see RAILS_ROOT/extensions/pages/pad_page/README
#
require 'etherpad-lite'

# This matches the API key defined in etherpad-lite/APIKEY.txt
# Copy the key to config/etherpad-api-key.txt
# Note: you could as well read that file if your rails user can do it.
ETHERPAD_API_KEY = IO.read(File.expand_path('../../etherpad-api-key.txt', __FILE__))

