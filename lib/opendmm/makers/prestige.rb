base_uri 'www.prestige-av.com'
cookies(age_auth: 1)

register_product(
  /^(ABP|ABS|ABY|BRA|CHN|CHS|DOM|EDD|ESK|EZD|HAZ|HON|INU|JBS|JOB|LLR|MAS|MBD|MDC|MEK|MMY|NDR|NOF|OSR|PPB|PPP|PPT|RAW|SAD|SGA|SPC|SRS|TAP|TDT|TRD|WAT|WPC|XND|YRH|YRZ)-?(\d{3})$/i,
  '/goods/goods_detail.php?sku=#{$1.upcase}-#{$2}',
)

private

def self.parse_product_html(html)
  specs = Utils.hash_from_dl(html.css('div.product_detail_layout_01 dl.spec_layout'))
  descriptions = parse_descriptions(html)
  {
    actresses:       parse_actresses(specs['出演：']),
    cover_image:     html.at_css('div.product_detail_layout_01 p.package_layout a.sample_image')['href'],
    description:     [ descriptions['作品情報'].text, descriptions['レビュー'].text ].join,
    genres:          specs['ジャンル：'].css('a').map(&:text),
    # TODO: Parse complete label, for example
    #       'ABSOLUTELY P…' should be 'ABSOLUTELY PERFECT'
    label:           specs['レーベル：'].text,
    maker:           specs['メーカー名：'].text,
    movie_length:    specs['収録時間：'].text,
    release_date:    specs['発売日：'].text,
    sample_images:   descriptions['サンプル画像'].css('a.sample_image').map { |a| a['href'] },
    series:          specs['シリーズ：'].text,
    thumbnail_image: html.at_css('#Wrapper > div.main_layout_01 > div.box_705 > div.section.product_layout_01 > div.product_detail_layout_01 > p > a > img')['src'],
    title:           html.css('div.product_title_layout_01').text,
  }
end

def self.parse_descriptions(html)
  layouts = html.css('div.product_layout_01 div.product_description_layout_01')
  titles = layouts.css('h2.title').map(&:text)
  contents = layouts.css('.contents')
  Hash[titles.zip(contents)]
end

def self.parse_actresses(node)
  if node.nil?
    nil
  elsif !node.css('a').empty?
    node.css('a').map(&:text)
  else
    [ node.text ]
  end
end
