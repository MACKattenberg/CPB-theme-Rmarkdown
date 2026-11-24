-- > [!DIAGRAM] magenta {#fig:optional-label width=60%}
-- Follow with a quoted three-column table and an optional caption paragraph.
local latex_output = FORMAT:match('latex') or FORMAT:match('beamer')
local html_output = FORMAT:match('html') or FORMAT:match('slidy') or FORMAT:match('revealjs') or FORMAT:match('s5') or FORMAT:match('dzslides')

local function write(blocks, format)
  return pandoc.write(pandoc.Pandoc(blocks), format, {wrap_text='none'}):gsub('%s+$', '')
end

function BlockQuote(quote)
  if not latex_output and not html_output then return nil end
  local first = quote.content[1]
  if not first or (first.t ~= 'Para' and first.t ~= 'Plain') then return nil end
  local marker = first.content[1]
  if not marker or marker.t ~= 'Str' or marker.text ~= '[!DIAGRAM]' then return nil end
  local header = pandoc.utils.stringify(first.content)
  local color = header:match('^%[!DIAGRAM%]%s*(%a*)')
  if color == '' then color = 'magenta' end
  if color ~= 'magenta' and color ~= 'blue' then
    error('A diagram color must be magenta or blue.')
  end
  local width_text = header:match('width%s*=%s*"?([%d%.]+)%%')
  if header:find('width%s*=') and not width_text then
    error('Use a percentage for diagram width, for example width=60%.')
  end
  local width = tonumber(width_text or '60')
  if not width or width <= 0 or width > 100 then error('Diagram width must be between 0 and 100%.') end
  local label = header:match('{#([%w:_%.%-]+)')
  local table_block, caption
  for i = 2, #quote.content do
    local block = quote.content[i]
    if block.t == 'Table' and not table_block then table_block = block
    elseif (block.t == 'Para' or block.t == 'Plain') and not caption then caption = block
    else error('A diagram needs one three-column table and at most one caption paragraph.') end
  end
  if not table_block then error('A diagram needs a Markdown table: Box | Text | Caption.') end
  if #table_block.colspecs ~= 3 then error('A diagram table must have exactly three columns: Box | Text | Caption.') end
  local rows = {}
  for _, body in ipairs(table_block.bodies) do
    for _, row in ipairs(body.head) do rows[#rows + 1] = row end
    for _, row in ipairs(body.body) do rows[#rows + 1] = row end
  end
  if #rows < 1 or #rows > 4 then error('A CPB diagram must contain between one and four box rows.') end
  if latex_output then
    local parts = {'\\begin{figure}\n\\centering\n\\resizebox{' .. (width / 100) .. '\\linewidth}{!}{%\n',
      '\\cpbdiagram{' .. color .. '}{' .. #rows .. '}{%\n'}
    for _, row in ipairs(rows) do
      local cells = {}
      for _, cell in ipairs(row.cells) do cells[#cells + 1] = '{' .. write(cell.contents, 'latex') .. '}' end
      parts[#parts + 1] = '\\cpbdiagramitem' .. table.concat(cells) .. '\n'
    end
    parts[#parts + 1] = '}}\n'
    if caption then parts[#parts + 1] = '\\caption{' .. write({pandoc.Plain(caption.content)}, 'latex') .. '}\n' end
    if label then parts[#parts + 1] = '\\label{' .. label .. '}\n' end
    parts[#parts + 1] = '\\end{figure}'
    return pandoc.RawBlock('latex', table.concat(parts))
  end
  local main = color == 'blue' and '#154273' or '#E5007D'
  local light = color == 'blue' and '#DAEDF7' or '#fad1e8'
  local parts = {'<figure class="cpb-diagram"' .. (label and (' id="' .. label .. '"') or '') ..
    ' style="width:' .. width .. '%;margin:1em auto;text-align:center;">',
    '<div style="display:flex;align-items:flex-start;gap:0.35em;">'}
  for i, row in ipairs(rows) do
    if i > 1 then parts[#parts + 1] = '<span aria-hidden="true" style="color:' .. main .. ';align-self:flex-start;margin-top:1.8em;">&#8594;</span>' end
    parts[#parts + 1] = '<div style="flex:1 1 0;min-width:0;">' ..
      '<div style="border-radius:0.4em;overflow:hidden;">' ..
      '<div style="background:' .. main .. ';color:white;padding:0.4em;font-weight:bold;">' .. write(row.cells[1].contents, 'html') .. '</div>' ..
      '<div style="background:' .. light .. ';color:#333;padding:0.6em;min-height:2.5em;">' .. write(row.cells[2].contents, 'html') .. '</div></div>' ..
      '<div style="color:' .. main .. ';font-size:0.8em;font-style:italic;">' .. write(row.cells[3].contents, 'html') .. '</div></div>'
  end
  parts[#parts + 1] = '</div>'
  if caption then parts[#parts + 1] = '<figcaption>' .. write({pandoc.Plain(caption.content)}, 'html') .. '</figcaption>' end
  parts[#parts + 1] = '</figure>'
  return pandoc.RawBlock('html', table.concat(parts, '\n'))
end
