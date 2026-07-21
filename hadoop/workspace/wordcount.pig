-- Load text
lines = LOAD '/input/input.txt'
    USING TextLoader()
    AS (line:chararray);

-- Split into words
words = FOREACH lines GENERATE
    FLATTEN(TOKENIZE(line)) AS word;

-- Group identical words
grp = GROUP words BY word;

-- Count occurrences
counts = FOREACH grp GENERATE
    group AS word,
    COUNT(words) AS count;

-- Save results
STORE counts INTO '/output/wordcount'
    USING PigStorage('\t');
