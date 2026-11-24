-- A .split level-two heading and <!-- right --> create two equal columns.
local is_latex = FORMAT:match('latex') or FORMAT:match('beamer')
local is_html = FORMAT:match('html') or FORMAT:match('slidy') or FORMAT:match('revealjs') or FORMAT:match('s5') or FORMAT:match('dzslides')

local function has_class(el, name)
  for _, class in ipairs(el.classes) do
    if class == name then return true end
  end
  return false
end

function Pandoc(doc)
  if not is_latex and not is_html then return doc end
  local output, heading, content = {}, nil, {}
  local function flush()
    if not heading then return end
    output[#output + 1] = heading
    if not has_class(heading, 'split') then
      for _, block in ipairs(content) do output[#output + 1] = block end
      return
    end
    local left, right, found = {}, {}, false
    for _, block in ipairs(content) do
      if block.t == 'RawBlock' and block.format == 'html'
          and block.text:match('^%s*<!%-%-%s*right%s*%-%->%s*$') then
        if found then error('A .split slide must contain only one <!-- right --> divider.') end
        found = true
      else
        local target = found and right or left
        target[#target + 1] = block
      end
    end
    if not found or #left == 0 or #right == 0 then
      error('Slide "' .. pandoc.utils.stringify(heading.content) ..
        '": use one <!-- right --> divider on its own line, with content on both sides.')
    end
    -- Keep ordinary images inside their column in either output format.
    local function fit_images(blocks)
      local div = pandoc.Div(blocks)
      return div:walk({Image = function(image)
        if not image.attributes.width then image.attributes.width = '100%' end
        if is_html then
          image.attributes.style = (image.attributes.style or '') .. ';max-width:100%;height:auto;object-fit:contain;'
        end
        return image
      end}).content
    end
    left, right = fit_images(left), fit_images(right)
    if is_latex then
      output[#output + 1] = pandoc.RawBlock('latex', '\\begin{columns}[T,onlytextwidth]\n\\begin{column}{0.48\\textwidth}')
      for _, block in ipairs(left) do output[#output + 1] = block end
      output[#output + 1] = pandoc.RawBlock('latex', '\\end{column}\n\\hfill\n\\begin{column}{0.48\\textwidth}')
      for _, block in ipairs(right) do output[#output + 1] = block end
      output[#output + 1] = pandoc.RawBlock('latex', '\\end{column}\n\\end{columns}')
    else
      output[#output + 1] = pandoc.Div({
        pandoc.Div(left, pandoc.Attr('', {'cpb-split-column'}, {style='flex:1 1 0;min-width:0;'})),
        pandoc.Div(right, pandoc.Attr('', {'cpb-split-column'}, {style='flex:1 1 0;min-width:0;'}))
      }, pandoc.Attr('', {'cpb-split-columns'}, {style='display:flex;align-items:flex-start;gap:4%;'}))
    end
  end
  for _, block in ipairs(doc.blocks) do
    if block.t == 'Header' and block.level <= 2 then
      flush()
      heading, content = block, {}
    elseif heading then
      content[#content + 1] = block
    else
      output[#output + 1] = block
    end
  end
  flush()
  doc.blocks = output
  return doc
end
