This application gives you easy access to eNanoMapper ontology terms and nanomaterials data stored in a triple-store database. 

---
#### Viewer
On this page you can search for complex data from a triple-store and view the results as easy understandable graphics. Dendrogram is a tree based vector graphic showing relations as bonds from node to node ordered from left to right. Sunburst is an interactive pie chart vector graphic aiming this approach with the number of circles around the center, where each color reflects a bond. By click on a colored field the graphic will zoom in so that this field gets the center of the graphic. Those two graphics can be useful to get a first impression for relationships of data and can be a starting point for deeper [SPARQL](https://www.w3.org/TR/rdf-sparql-query/) queries on the second page.  
In order to get a proper result it is necessary to write [SPARQL](https://www.w3.org/TR/rdf-sparql-query/) queries in a special sequence. Please refer to the template given in the editor. A `child` needs to have a binding node to `root` and `parent` and the names must be the same. Obviously you can name the variables like you want.  
Please also note the part `{,5}` which is a [property path](https://www.w3.org/TR/sparql11-property-paths/) and for this example used as delimiter for level of results. For most regular expressions search terms you also need to pass '@en' at the end like `"algorithm type"@en` .
 
---
#### Sparql
This page allows you to write [SPARQL](https://www.w3.org/TR/rdf-sparql-query/) queries without any restrictions and with full [SPARQL](https://www.w3.org/TR/rdf-sparql-query/) syntax support including subqueries. The result can be downloaded to your computer. Please choose one of the output formats from the drop-down list. There is also an option to render results as HTML table to the page.
