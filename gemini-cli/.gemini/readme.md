Via this folder, you can **configure MCP servers accesible by Gemini CLI.**


---

Using GeminiCLI:

```sh
npx https://github.com/google-gemini/gemini-cli
export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
#gemini

#gemini --debug -p "Can you list the files under the ./input-sources/sample-project folder?"
```

```sh
#source .env
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works in a few words"
          }
        ]
      }
    ]
  }'
```

---

Example prompts:

```
Could you look at the structure of the input-sources/some-project folder and generate a documentation for Skeleton for it?


Your task is to create **technical documentation for the cloned project** and write a post as markdown file where specified.


**Output Format (Astro Theme Template):**

The final documentation should be formatted to be easily integrated with the Astro theme located at `/home/jalcocert/Desktop/IT/project-documentation-generator-geminiCLI/docs/src/content/docs/reference`.

Please consider the following:

* **Markdown Output:** Generate the documentation in Markdown format (`.md` files) as this is the primary format for Astro content.
* **Frontmatter:** Respect the following Astro frontmatter at the beginning of each Markdown file (e.g., `title`, `description`)

* Add H2/H3 and bullet points to structure the information of the post
* Provide a final section in H2 to the post so that we can see the files that have been used to generate it
* Make a plan also as per the information of the tree -L commands to enhance the documentation at a later stage.
* Inspect also the most likely files of the project to provide value and direction on tech details
* Consider information like repository structure and real app files, not markdowns
```
`