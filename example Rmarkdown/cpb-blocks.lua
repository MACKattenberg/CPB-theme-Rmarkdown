-- Markdown callouts: > [!BLOCK] Title, followed by quoted Markdown content.
local is_latex = FORMAT:match('latex') or FORMAT:match('beamer')
local is_html = FORMAT:match('html') or FORMAT:match('slidy') or FORMAT:match('revealjs') or FORMAT:match('s5') or FORMAT:match('dzslides')

function BlockQuote(quote)
  if not is_latex and not is_html then return nil end
  local first = quote.content[1]
  if not first or (first.t ~= 'Para' and first.t ~= 'Plain') then return nil end
  local marker = first.content[1]
  if not marker or marker.t ~= 'Str' or marker.text ~= '[!BLOCK]' then return nil end

  local title, remainder, in_body = pandoc.Inlines({}), pandoc.Inlines({}), false
  for i = 2, #first.content do
    local inline = first.content[i]
    if not in_body and (inline.t == 'SoftBreak' or inline.t == 'LineBreak') then
      in_body = true
    elseif in_body then
      remainder:insert(inline)
    elseif #title > 0 or inline.t ~= 'Space' then
      title:insert(inline)
    end
  end
  if #title == 0 then title = pandoc.Inlines({pandoc.Str('Block')}) end
  local body = pandoc.Blocks({})
  if #remainder > 0 then body:insert(pandoc.Para(remainder)) end
  for i = 2, #quote.content do body:insert(quote.content[i]) end

  if is_latex then
    local heading = pandoc.write(pandoc.Pandoc({pandoc.Plain(title)}), 'latex'):gsub('%s+$', '')
    return pandoc.Div(body, pandoc.Attr('', {'cpb-block'}, {title=heading}))
  end
  local heading = pandoc.Div({pandoc.Plain(title)}, pandoc.Attr('', {'cpb-block-title'}, {
    style='background:#E5007D;color:white;padding:0.25em 0.6em;font-weight:bold;'
  }))
  local contents = pandoc.Div(body, pandoc.Attr('', {'cpb-block-body'}, {
    style='background:#e6f6ff;color:#333;padding:0.4em 0.6em;'
  }))
  return pandoc.Div({heading, contents}, pandoc.Attr('', {'cpb-block'}, {
    style='border-radius:0.3em;overflow:hidden;box-shadow:0.1em 0.1em 0.2em #aaa;margin:0.7em 0;'
  }))
end
