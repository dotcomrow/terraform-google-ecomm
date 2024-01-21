#!/bin/bash

CONTENTS=""
LIST=$(find . -name '*.graphql')
for f in $LIST; do
  FILENAME=$(echo "$f" | rev | cut -d "/" -f1 | rev)
  CONTENTS="$CONTENTS""cat $FILENAME <<EOF" >> CONTENTS
  CONTENTS="$CONTENTS$(cat $f)" >> CONTENTS
  CONTENTS="$CONTENTS""EOF\n" >> CONTENTS
done

echo -e $CONTENTS > graphql_contents
sed -e '/GRAPHQL_CONTENTS/{r graphql_contents' -e 'd;}' build_graphql_schema.sh > build_graphql_schema.sh.new