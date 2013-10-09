agent = require 'superagent'
fs = require 'fs'
rimraf = require 'rimraf'

class Scraper

  constructor: ->

    rimraf.sync 'content/md'
    fs.mkdirSync 'content/md'

    rimraf.sync 'content/html'
    fs.mkdirSync 'content/html'

    agent.get "https://devcenter.heroku.com/api/v1/articles.json", (err, res) ->
      articles = {}

      # Make articles an object with slugs as keys
      for article in res.body
        articles[article.slug] = article

      for slug, article of articles

        # Hit a different endpoint to get the markdown and html
        agent.get article.api_url, (err, res) ->
          article = articles[res.body.slug]
          console.log article.slug

          # Copy attributes like content, html_content to the article
          article[k] = v for k,v of res.body

          # Inject YAML frontmatter
          article.content = """---\ntitle: #{article.title}\nslug: #{article.slug}\nurl: #{article.view_url}\ndescription: #{article.meta_description}\n---\n\n#{article.content}"""

          fs.writeFileSync "./content/md/#{article.slug}.md", article.content
          fs.writeFileSync "./content/html/#{article.slug}.html", article.html_content

new Scraper()