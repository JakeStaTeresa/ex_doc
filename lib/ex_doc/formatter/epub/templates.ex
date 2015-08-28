defmodule ExDoc.Formatter.EPUB.Templates do
  @moduledoc """
  Handle all template interfaces for the EPUB formatter.
  """

  require EEx
  alias ExDoc.Formatter.HTML.Templates, as: H

  @content_template_doc """
  Creates the [Package Document Definition](http://www.idpf.org/epub/30/spec/epub30-publications.html#sec-package-def),
  this definition encapsulates the publication metadata and the resource
  information that constitute the EPUB publication. This definition also
  includes the default reading order.
  """
  @module_template_doc """
  Creates a chapter which contains all the details about an individual module,
  this chapter can include the following sections: *functions*, *macros*,
  *types*, *callbacks*.
  """
  @nav_template_doc """
  Creates the table of contents. This template follows the
  [EPUB Navigation Document Definition](http://www.idpf.org/epub/30/spec/epub30-contentdocs.html#sec-xhtml-nav).
  """
  @extra_template_doc """
  Creates a new chapter when the user provides additional files.
  """
  @title_template_doc """
  Creates the cover page for the EPUB document.
  """
  @toc_template_doc """
  Creates an *Navigation Center eXtended* document (as defined in OPF 2.0.1),
  this is for compatibility purposes with EPUB 2 Reading Systems.  EPUB 3
  Reading Systems must ignore the NCX in favor of the
  [EPUB Navigation Document](http://www.idpf.org/epub/30/spec/epub30-contentdocs.html#sec-xhtml-nav).
  """

  @doc """
  Generate content from the module template for a given `node`
  """
  def module_page(config, node) do
    types = H.group_types(node)
    module_template(config, node, types.types, types.functions, types.macros, types.callbacks)
  end

  defp extra_title(path), do: path |> String.upcase |> Path.basename(".MD")

  templates = [
    content_template: {[:config, :nodes, :uuid, :datetime], @content_template_doc},
    module_template: {[:config, :module, :types, :functions, :macros, :callbacks], @module_template_doc},
    nav_template: {[:config, :nodes], @nav_template_doc},
    extra_template: {[:config, :content], @extra_template_doc},
    title_template: {[:config], @title_template_doc},
    toc_template: {[:config, :nodes, :uuid], @toc_template_doc},
  ]

  Enum.each templates, fn({ name, {args, docs} }) ->
    filename = Path.expand("templates/#{name}.eex", __DIR__)
    @doc docs
    EEx.function_from_file :def, name, filename, args
  end
end
