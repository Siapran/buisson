local ffi = require("ffi")
local hd = require("hoedown")

local flags = hd.HOEDOWN_HTML_ESCAPE
local extensions = bit.bor(
  hd.HOEDOWN_EXT_BLOCK,
  hd.HOEDOWN_EXT_SPAN
)

return function ( markdown )
	local renderer = hd.hoedown_html_renderer_new(flags, 0)
	local document = hd.hoedown_document_new(renderer, extensions, 16);
	local html = hd.hoedown_buffer_new(16)

	hd.hoedown_document_render(document, html, markdown, #markdown);

	local output = hd.hoedown_buffer_new(16)
	hd.hoedown_html_smartypants(output, html.data, html.size)

	local string = ffi.string(output.data, output.size)

	hd.hoedown_buffer_free(html)
	hd.hoedown_buffer_free(output)
	hd.hoedown_document_free(document)
	hd.hoedown_html_renderer_free(renderer)

	return string
end
