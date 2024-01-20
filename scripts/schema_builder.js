import { BigQuery } from "@google-cloud/bigquery";
import { GraphQLSchema, 
  GraphQLObjectType,
  GraphQLString, 
  GraphQLInt, 
  GraphQLBoolean,
  introspectionFromSchema } from "graphql";
import fs from 'fs';
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

  async function fetchSchemas() {
    const [tables] = await bigquery.dataset(options.datasetId).getTables();

    var tableList = [];
    var graphqlObjects = [];
    for (var table of tables) {
      var tableMetadata = await getTableMetadata(table);
      tableList.push(tableMetadata);
    }

    for (var metadata of tableList) {
      var fields = {};
      metadata[0].schema.fields.forEach((field) => {
        fields[field.name] = {
          type: parseType(field.type),
          description: field.description,
        };
      });

      var types = [];
      types.push( new GraphQLObjectType({
        name: metadata[0].tableReference.tableId,
        fields: fields,
      }));

      var graphqlSchema = new GraphQLSchema({
        query: new GraphQLObjectType({
          name: 'Query',
          fields: metadata[0].tableReference.tableId
        }),
        types: types
      });

      graphqlObjects.push(
        graphqlSchema
      );
    }

    return graphqlObjects;
  }

  async function query() {
    var schemas = await fetchSchemas();
    // const storage = new Storage();
    const mergedSchema = mergeSchemas({
      schemas: schemas
    })
    const schema_json = introspectionFromSchema(mergedSchema);
    let json = JSON.stringify(schema_json);
    // console.log(json);
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
