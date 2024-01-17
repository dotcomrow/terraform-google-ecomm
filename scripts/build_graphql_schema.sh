curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node

cat > package.json <<EOF
{
    "name": "schema-builder",
    "version": "1.0.0",
    "dependencies": {
      "serialize-error": "^11.0.3"
    },
    "devDependencies": {
      "webpack": "^5.89.0",
      "webpack-cli": "^5.1.4",
      "babel-loader": "^9.1.3",
      "path-browserify": "^1.0.1",
      "crypto-browserify": "3.12.0",
      "stream-browserify":"^3.0.0",
      "https-browserify":"^1.0.0",
      "os-browserify":"^0.3.0",
      "browserify-zlib":"^0.2.0",
      "util":"^0.12.5",
      "url":"^0.11.3",
      "stream-http":"^3.2.0",
      "assert":"^2.1.0",
      "@google-cloud/bigquery":"^7.3.0",
      "fs":"^0.0.1-security",
      "querystring-es3":"^0.2.1",
      "net-browserify":"^0.2.4",
      "process":"^0.11.10",
      "buffer":"^6.0.3",
      "graphql":"^16.8.1",
      "@google-cloud/storage":"^7.7.0"
    },
    "private": true,
    "type": "module",
    "main": "index.js"
}EOF

npm install

cat > schema_builder.js <<EOF
import { BigQuery } from "@google-cloud/bigquery";
import { GraphQLSchema, GraphQLScalarType, GraphQLObjectType } from "graphql";

function main() {
  const options = {
    keyFilename: "key.json",
    projectId: "$1",
    datasetId: "$2",
  };
  const bigquery = new BigQuery(options);

  function getTableMetadata(table) {
    async function getTM(table) {
      const metadata = await table.getMetadata();
      return metadata;
    }
    return getTM(table);
  }

  async function fetchSchemas() {
    const [tables] = await bigquery.dataset(options.datasetId).getTables();

    var tableList = [];
    var graphqlObjects = [];
    for (var table of tables) {
      var tableMetadata = await getTableMetadata(table);
      tableList.push(tableMetadata);
    }

    for (var metadata of tableList) {
      var fields = [];
      metadata[0].schema.fields.forEach((field) => {
        fields[field.name] = {
          type: field.type,
          description: field.description,
        };

        graphqlObjects.push(
          new GraphQLObjectType({
            name: metadata[0].tableReference.tableId,
            fields: fields,
          })
        );
      });
    }

    return graphqlObjects;
  }

  async function query() {
    var schemas = await fetchSchemas();
    

  }
  query();
}
main(...process.argv.slice(2));
EOF

printf '%s' "$GOOGLE_CREDENTIALS" > key.json
node schema_builder.js

SHA="test"

cat <<EOF
{
  "sha": "$SHA"
}
EOF