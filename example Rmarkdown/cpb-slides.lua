-- Convert Markdown slide headings to the original CPB frame layouts.
-- Use the LaTeX writer for each slide body to avoid Pandoc's Beamer defaults.
if not (FORMAT:match('latex') or FORMAT:match('beamer')) then return {} end
local function latex(blocks)
  local result = pandoc.write(pandoc.Pandoc(blocks), 'latex', {wrap_text = 'none'})
  -- A paragraph before a nested list adds space absent from the CPB source.
  return result:gsub('\n\n(%s*\\begin{itemize})', '\n%1')
end
local function raw(s) return pandoc.RawBlock('latex', s) end
local function has(el, name)
  for _, c in ipairs(el.classes) do if c == name then return true end end
  return false
end
local function text(inlines)
  return latex({pandoc.Plain(inlines)}):gsub('%s+$', '')
end

function Div(el)
  if has(el, 'cpb-block') then
    local title = el.attributes.title or ''
    return raw('\\begin{block}{' .. title .. '}\n' .. latex(el.content) .. '\n\\end{block}')
  end
end

function Code(el)
  for _, delimiter in ipairs({'|', '!', '+'}) do
    if not el.text:find(delimiter, 1, true) then
      return pandoc.RawInline('latex', '\\verb' .. delimiter .. el.text .. delimiter)
    end
  end
end

function Image(el)
  if has(el, 'cpb-figure') then
    return pandoc.RawInline('latex',
      '\\begin{figure}[H]\n\\centering\n\\vspace{-0.5cm}\n' ..
      '\\includegraphics[scale=' .. (el.attributes.scale or '1') .. ']{' .. el.src .. '}\n' ..
      '\\vspace{-0.5cm}\n\\caption{\\scriptsize{' .. text(el.caption) .. '}}\n' ..
      '\\label{' .. el.identifier .. '}\n\\end{figure}')
  end
end

function Pandoc(doc)
  local output, heading, content = {}, nil, {}
  local function flush()
    if not heading then return end
    local kind = heading.attributes.layout or 'content'
    local title = text(heading.content)
    local body = latex(content)
    local result
    if kind == 'title' then
      result = '\\cpbtitelframe'
    elseif kind == 'end' then
      result = '\\cpbeindframe'
    elseif kind == 'section' then
      result = '\\cpbsectie{' .. title .. '}{' .. (heading.attributes.subtitle or '') .. '}'
    elseif kind == 'agenda' then
      result = '\\cpbinhoudframe{' .. body .. '}'
    else
      local options = {}
      for _, option in ipairs({'plain', 'fragile', 'noframenumbering'}) do
        if has(heading, option) then table.insert(options, option) end
      end
      if body:find('\\verb', 1, true) and not has(heading, 'fragile') then
        table.insert(options, 'fragile')
      end
      if heading.attributes.allowframebreaks then
        table.insert(options, 'allowframebreaks=' .. heading.attributes.allowframebreaks)
      end
      local opt = #options > 0 and ('[' .. table.concat(options, ',') .. ']') or ''
      if has(heading, 'untitled') then title = '' end
      result = '\\begin{frame}' .. opt .. '{' .. title .. '}\n'
      if heading.identifier ~= '' then result = result .. '\\label{' .. heading.identifier .. '}\n' end
      result = result .. body .. '\n\\end{frame}'
    end
    table.insert(output, raw(result))
  end
  for _, block in ipairs(doc.blocks) do
    if block.t == 'Header' and block.level == 2 then
      flush()
      heading, content = block, {}
    elseif heading then
      table.insert(content, block)
    else
      table.insert(output, block)
    end
  end
  flush()
  doc.blocks = output
  return doc
end
