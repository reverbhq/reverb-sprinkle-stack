package :libxml do
  description "LibXML Dependencies for Nokogiri"

  apt %w{libxml2 libxml2-dev libxslt1-dev}

  verify do
    has_apt "libxml2"
    has_apt "libxml2-dev"
    has_apt "libxslt1-dev"
  end
end
