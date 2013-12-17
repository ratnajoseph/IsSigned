require 'openssl'
# require 'origami'

module Checksign
  
  begin
  require 'origami'
rescue LoadError
  ORIGAMIDIR = "C:\RailsInstaller\Ruby1.9.3\lib\ruby\gems\1.9.1\gems\origami-1.2.4\lib"
  $: << ORIGAMIDIR
  require 'origami'
end

include Origami

# Code below is based on documentation available on
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/openssl/rdoc/OpenSSL.html
  OUTPUTFILE = "test.pdf"

  # for PDF Sign
def self.Signpdf

key = OpenSSL::PKey::RSA.new 2048

open 'private_key.pem', 'w' do |io| io.write key.to_pem end
open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

cipher = OpenSSL::Cipher::Cipher.new 'AES-128-CBC'
pass_phrase = 'Origami rocks'

key_secure = key.export cipher, pass_phrase

open 'private_key.pem', 'w' do |io|
  io.write key_secure
end

#Create the certificate

name = OpenSSL::X509::Name.parse 'CN=nobody/DC=example'

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 0
cert.not_before = Time.now
cert.not_after = Time.now + 3600

cert.public_key = key.public_key
cert.subject = name


contents = ContentStream.new.setFilter(:FlateDecode)
contents.write OUTPUTFILE,:x => 350, :y => 750, :rendering => Text::Rendering::STROKE, :size => 30

pdf = PDF.read('kimbo.pdf')


# Open certificate files

sigannot = Annotation::Widget::Signature.new
sigannot.Rect = Rectangle[:llx => 89.0, :lly => 386.0, :urx => 190.0, :ury => 353.0]

#page.add_annot(sigannot)

# Sign the PDF with the specified keys
pdf.sign(cert, key,
         :method => 'adbe.pkcs7.sha1',
         :annotation => sigannot,
         :location => 'India',
         # :contact => nil,
         :reason => 'Proof of Concept'
)

#  puts pdf

# Save the resulting file
pdf.save(OUTPUTFILE)

 
end #end sign

  # for PDF verification

def self.Verifypdf

end #end verify

  
end #end Module
