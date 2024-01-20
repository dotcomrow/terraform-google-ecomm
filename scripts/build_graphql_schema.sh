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
      "@graphql-tools/schema":"^9.0.0",
      "node-cloudflare-r2":"0.1.5"
    },
    "private": true,
    "type": "module",
    "main": "index.js"
}
EOF

npm install

cat > schema_builder.js <<EOF
import { BigQuery } from "@google-cloud/bigquery";
import { GraphQLSchema, 
  GraphQLObjectType,
  GraphQLString, 
  GraphQLInt, 
  GraphQLBoolean,
  introspectionFromSchema,
  buildSchema,
  graphqlSync } from "graphql";
import fs from 'fs';
import path from 'path';
import { serializeError } from "serialize-error";
import { mergeSchemas } from '@graphql-tools/schema';
import { R2 } from 'node-cloudflare-r2';

async function main() {
  const options = {
    // bucket_name: "graphql_schemas"

    keyFilename: "key.json",
    projectId: "$1",
    datasetId: "$2",
    // bucket_name: "$3",
  };
  const bigquery = new BigQuery(options);
  // const storage = new Storage({
  //   projectId: options.projectId,
  //   keyFilename: "storage_admin_key.json",
  // });

  const r2 = new R2({
      accountId: "$4",
      accessKeyId: "$5",
      secretAccessKey: "$6",
  });

  const bucket = r2.bucket("$3");
  // const bucket = r2.bucket("schemas");
  const fileName = 'graphql_schema.json';

  function getTableMetadata(table) {
    async function getTM(table) {
      const metadata = await table.getMetadata();
      return metadata;
    }
    return getTM(table);
  }

  async function uploadFile() {
    
    // var generationMatchPrecondition = 0

    // const local_options = {
    //   destination: fileName,
    //   // Optional:
    //   // Set a generation-match precondition to avoid potential race conditions
    //   // and data corruptions. The request to upload is aborted if the object's
    //   // generation number does not match your precondition. For a destination
    //   // object that does not yet exist, set the ifGenerationMatch precondition to 0
    //   // If the destination object already exists in your bucket, set instead a
    //   // generation-match precondition using its generation number.
    //   preconditionOpts: {ifGenerationMatch: generationMatchPrecondition},
    // };

    // await storage.bucket(options.bucket_name).upload(fileName, local_options);

    // Set your bucket's public URL
    // bucket.provideBucketPublicUrl('https://pub-xxxxxxxxxxxxxxxxxxxxxxxxx.r2.dev');

    // console.log(await bucket.exists());
    // true

    const upload = await bucket.uploadFile(fileName, fileName, {}, "application/json");
  }

  function parseType(field) {
    switch (field.type) {
      case "STRING":
        return GraphQLString;
      case "INTEGER":
        return GraphQLInt;
      case "BOOLEAN":
        return GraphQLBoolean;
      case "FLOAT":
        return GraphQLFloat;
      case "TIMESTAMP":
        return GraphQLString;
      case "DATE":
        return GraphQLString;
      case "TIME":
        return GraphQLString;
      case "DATETIME":
        return GraphQLString;
      case "GEOGRAPHY":
        return GraphQLString;
      case "NUMERIC":
        return GraphQLInt;
      default:
        return GraphQLString;
    }
  }

  async function getRegularSchema() {
    var regularFiles = fromDir('./modules', '.graphql');
    var adminFiles = fromDir('./modules', '.admin.graphql');
    regularFiles = regularFiles.filter( x => !new Set(adminFiles).has(x) );
    
    var combined = "";

    for(let x = 0; x < regularFiles.length; x++) {
      const data = fs.readFileSync(regularFiles[x],{ encoding: 'utf8', flag: 'r' });
      combined += data;
    }
    return buildSchema(combined);
  }

  async function getAdminSchema() {
    var adminFiles = fromDir('./modules', '.admin.graphql');
    
    var combined = "";

    for(let x = 0; x < adminFiles.length; x++) {
      const data = fs.readFileSync(adminFiles[x],{ encoding: 'utf8', flag: 'r' });
      combined += data;
    }
    console.log(combined)
    return buildSchema(combined);
  }

  async function fetchSchemas() {
    // const [tables] = await bigquery.dataset(options.datasetId).getTables();

    // var tableList = [];
    var graphqlObjects = [];
    // for (var table of tables) {
    //   var tableMetadata = await getTableMetadata(table);
    //   tableList.push(tableMetadata);
    // }

    // for (var metadata of tableList) {
    //   var fields = {};
    //   metadata[0].schema.fields.forEach((field) => {
    //     fields[field.name] = {
    //       type: parseType(field.type),
    //       description: field.description,
    //     };
    //   });

    //   var types = [];
    //   types.push( new GraphQLObjectType({
    //     name: metadata[0].tableReference.tableId,
    //     fields: fields,
    //   }));

    //   var graphqlSchema = new GraphQLSchema({
    //     query: new GraphQLObjectType({
    //       name: 'Query',
    //       fields: {
    //         _dummy: { type: GraphQLString }
    //       }
    //     }),
    //     types: types
    //   });

    //   graphqlObjects.push(
    //     graphqlSchema
    //   );
    // }



    return graphqlObjects;
  }

  function fromDir(startPath, filter) {

      // console.log('Starting from dir '+startPath+'/');

      if (!fs.existsSync(startPath)) {
          console.log("no dir ", startPath);
          return;
      }

      var foundList = [];
      var files = fs.readdirSync(startPath);
      for (var i = 0; i < files.length; i++) {
          var filename = path.join(startPath, files[i]);
          var stat = fs.lstatSync(filename);
          if (stat.isDirectory()) {
              fromDir(filename, filter).forEach((item) => {
                foundList.push(item);
              }); //recurse
          } else if (filename.endsWith(filter)) {
              foundList.push(filename);
          };
      };
      return foundList;
  };

  async function query() {
    // var schemas = await fetchSchemas();
    
    // const storage = new Storage();
    // const mergedSchema = mergeSchemas({
    //   schemas: schemas
    // })
    // const schema_json = introspectionFromSchema(mergedSchema);

    const schema_json = introspectionFromSchema(await getRegularSchema());
    // const admin_schema_json = introspectionFromSchema(await getAdminSchema());

    let json = JSON.stringify(schema_json);
    // console.log(json);

    // let admin_json = JSON.stringify(admin_schema_json);
    // console.log(admin_json);

    await fs.writeFile(fileName, json,{ flush:true }, (err) => {
      err && console.error(err)
    });
    fs.readFile(fileName, 'utf8', async (err, data) => {
      if (err) {
        console.error(err)
        return
      }
      await uploadFile();
    });
  }

  try {
    await query();
  } catch (err) {
    const responseError = serializeError(err);
    console.error(responseError);
  }
}
main(...process.argv.slice(2));
EOF

# ls -al
printf '%s' "$GOOGLE_CREDENTIALS" > key.json
# printf '%s' "$STORAGE_ADMIN_CREDENTIALS" > storage_admin_key.json
node schema_builder.js

SHA="test"

cat <<EOF
{
  "sha": "$SHA"
}
EOF