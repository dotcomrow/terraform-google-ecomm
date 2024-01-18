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
}
EOF

npm install

cat > schema_builder.js <<EOF
import { BigQuery } from "@google-cloud/bigquery";
import { GraphQLSchema, GraphQLScalarType, GraphQLObjectType, introspectionFromSchema } from "graphql";
import { Storage } from '@google-cloud/storage';
import fs from 'fs';
import { serializeError } from "serialize-error";

function main() {
  const options = {
    keyFilename: "key.json",
    projectId: "$1",
    datasetId: "$2",
    bucket_name: "$3",
  };
  const bigquery = new BigQuery(options);
  const storage = new Storage();
  const fileName = 'graphql_schema.json';

  function getTableMetadata(table) {
    async function getTM(table) {
      const metadata = await table.getMetadata();
      return metadata;
    }
    return getTM(table);
  }

  async function uploadFile() {
    
    generationMatchPrecondition = 0

    const options = {
      destination: destFileName,
      // Optional:
      // Set a generation-match precondition to avoid potential race conditions
      // and data corruptions. The request to upload is aborted if the object's
      // generation number does not match your precondition. For a destination
      // object that does not yet exist, set the ifGenerationMatch precondition to 0
      // If the destination object already exists in your bucket, set instead a
      // generation-match precondition using its generation number.
      preconditionOpts: {ifGenerationMatch: generationMatchPrecondition},
    };

    await storage.bucket(bucket_name).upload(fileName, options);
    console.log(`${filePath} uploaded to ${bucketName}`);
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
    const storage = new Storage();
    const schema_json = introspectionFromSchema(schemas);
    let json = JSON.stringify(schema_json);
    fs.writeFile(fileName, json);
    ls -al
  }

  try {
    query();
  } catch (err) {
    const responseError = serializeError(err);
    console.error(responseError);
  }
}
main(...process.argv.slice(2));
EOF

ls -al
printf '%s' "$GOOGLE_CREDENTIALS" > key.json
node schema_builder.js

SHA="test"

cat <<EOF
{
  "sha": "$SHA"
}
EOF