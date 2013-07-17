# -*- coding: utf-8 -*-
require 'libgss'
require 'fontana_client_support'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

if ENV['SYNC_DIRECTLY'] =~ /yes|on|true/i
  Fontana::CommandUtils::system!("rake deploy:sync:update")
end

RSpec.configure do |config|

  # iOS開発環境が整っていない場合、SSLで接続する https://sandbox.itunes.apple.com/verifyreceipt が
  # オレオレ証明書を使っているので、その検証をができなくてエラーになってしまいます。
  # 本来ならば、信頼する証明書として追加する方が良いと思われますが、
  # ( http://d.hatena.ne.jp/komiyak/20130508/1367993536 )
  # 証明書自身の検証はローカルの開発環境で行うことができるので、ここでは単純に検証をスキップする
  # ように設定してしまいます。
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

end
