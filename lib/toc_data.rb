require 'nokogiri'

def toc_data(page_content)
  html_doc = Nokogiri::HTML::DocumentFragment.parse(page_content)
  header_ids = {}
  # get a flat list of headers
  headers =
    html_doc.css('h1, h2, h3').each_with_object([]) do |header, result|
      orig_id = header['id'] || 'header-id'
      header_ids[orig_id] ||= 0
      header_ids[orig_id] += 1
      header['id'] = "#{orig_id}-#{header_ids[orig_id]}" if header_ids[orig_id] > 1
      result.push({
        id: header['id'],
        content: header.children,
        title: header.children.to_s.gsub(/<[^>]*>/, ''),
        level: header.name[1].to_i,
        children: []
      })
    end

  [3,2].each do |header_level|
    header_to_nest = nil
    headers = headers.reject do |header|
      if header[:level] == header_level
        header_to_nest[:children].push header if header_to_nest
        true
      else
        header_to_nest = header if header[:level] < header_level
        false
      end
    end
  end

  [headers, html_doc.to_html]
end
