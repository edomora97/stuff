module ApplicationHelper
    class HTMLwithPygments < Redcarpet::Render::HTML
        def block_code(code, language)
            "<h3>#{language}</h3>" + if /\.rb$|Gemfile|Rakefile|ruby/ =~ language
                Pygments.highlight(code, lexer: "Ruby")
            elsif /scss$/ =~ language
                Pygments.highlight(code, lexer: "SCSS")
            elsif /css$/ =~ language
                Pygments.highlight(code, lexer: "CSS")
            elsif /html\.erb$|rhtml$/ =~ language
                Pygments.highlight(code, lexer: "RHTML")
            elsif /js\.erb$/ =~ language
                Pygments.highlight(code, lexer: "Javascript+Ruby")
            elsif /terminal|bash|zsh/ =~ language
                Pygments.highlight(code, lexer: "Bash")
            else
                Pygments.highlight(code)
            end
        end
    end

    def markdown(text)
        renderer = HTMLwithPygments.new(hard_wrap: true, filter_html: true)
        options = {
            autolink: true,
            no_intra_emphasis: true,
            fenced_code_blocks: true,
            lax_html_blocks: true,
            strikethrough: true,
            superscript: true
        }
        Redcarpet::Markdown.new(renderer, options).render(text).html_safe
    end
end
