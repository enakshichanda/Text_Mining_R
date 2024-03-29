# Text minig in R based on quateda tutorials at 
# Watanabe, Kohei and Stefan Müller. 2019. Quanteda Tutorials. 
# https://tutorials.quanteda.io.


# The core "quanteda" library
install.packages("quanteda")

# The package to load text from different formats
install.packages("readtext")

# Additional datasets from "quanteda" package
install.packages("devtools")
devtools::install_github("quanteda/quanteda.corpora")

# Wrapper for spaCy library of Python to be used
# for POS tagging, NER, and dependency parsing.
install.packages("spacyr")

# Package to classify documents based on seed words
install.packages("newsmap")



################################################
#                                              #
#         IMPORTING TEXTUAL DATA               #
#                                              #
################################################


# The "readtext" package is used to load text from different sources and formats
library(readtext)
library("jsonlite")

# Path to text data contained in the "readtext" package
DATA_PATH <- system.file("extdata/", package = "readtext")

# Check that path points to the data directory
print(DATA_PATH)

# Read text files in a directory which contains Universal Declerations of Human Rights 
list.files(paste0(DATA_PATH, "/txt/UDHR/"))
UNHR_files <- readtext(paste0(DATA_PATH, "/txt/UDHR/*"))
UNHR_files


# Read text files in to a dataframe and extract metadata 
list.files(paste0(DATA_PATH, "/txt/EU_manifestos/"))
EU_files <- readtext(paste0(DATA_PATH, "/txt/EU_manifestos/*.txt"),
                     docvarsfrom = "filenames", 
                     docvarnames = c("unit", "context", "year", "language", "party"),
                     dvsep = "_", 
                     encoding = "ISO-8859-1")
EU_files

# Read text from current and subfolders
list.files(paste0(DATA_PATH, "/txt/movie_reviews/"))

# The names of subfolders are appended at the start of filenames
movie_files <- readtext(paste0(DATA_PATH, "/txt/movie_reviews/*"),
                        docvarsfrom = "filenames", 
                        docvarnames = c("sentiment"))
movie_files

# Remove extra columns
movie_files <- movie_files[1:3]
movie_files


# Read data from JSON files
readtext(paste0(DATA_PATH, "/json/inaugural_sample.json"), text_field = "texts")

# Read JSON data into a dataframe
json_data <- as.data.frame(fromJSON(paste0(DATA_PATH, "/json/inaugural_sample.json")))

# Note the differecnce of first columns in two outputs.

# Import text from PDF files
readtext(paste0(DATA_PATH, "/pdf/UDHR/*.pdf"), 
         docvarsfrom = "filenames", 
         docvarnames = c("document", "language"),
         sep = "_")

# Import text from MS Word files
readtext(paste0(DATA_PATH, "/word/*.docx"))

# Import data from tabluar data

# using the "read.csv" function to load data in a dataframe
read.csv(paste0(DATA_PATH, "/csv/inaugCorpus.csv"))

# Using "readtext" to load data with document-level information
readtext(paste0(DATA_PATH, "/tsv/dailsample.tsv"), text_field = "speech")



# Download, uncompress a TAR archive
URL = "http://www.cs.cornell.edu/people/pabo/movie-review-data/rt-polaritydata.tar.gz"
download.file(URL, "rt-polaritydata.tar.gz")
untar("rt-polaritydata.tar.gz")

# Load sentence in dataframes
df_neg <- data.frame(sentence = readLines("./rt-polaritydata/rt-polarity.neg"), 
                     stringsAsFactors = FALSE)
df_neg['sentiment'] <- "neg"

df_pos <- data.frame(sentence = readLines("./rt-polaritydata/rt-polarity.pos"), 
                     stringsAsFactors = FALSE)
df_pos['sentiment'] <- "pos"

# Create corpus from data frames
corp_moives <- corpus(rbind(df_neg, df_pos), text_field='sentence')
summary(corp_moives,2)



################################################
#                                              #
#             BASIC OPERATIONS                 #
#                                              #
################################################

# Load the "quanteda" package
library(quanteda)

# The "data_char_ukimmig2010" is a named character vector which is part of the "quanteda" package.
summary(data_char_ukimmig2010)
names(data_char_ukimmig2010)


#===============================
#   Corpus    
#==============================


# -----------------------------
#   Costruct a corpus
# -----------------------------

# Create a corpus from the charater vector
ukimmig_corpus <- corpus(data_char_ukimmig2010,
                         docvars = data.frame(party = names(data_char_ukimmig2010)))
summary(ukimmig_corpus)

# Load tabluar data from in a data frame
dat_inaug <- readtext(paste0(DATA_PATH, "/csv/inaugCorpus.csv"), text_field = "texts")
summary(dat_inaug)

# Create a corpus from the data frame
corp_inaug <- corpus(dat_inaug)
summary(corp_inaug)

# Rename the document identifier to be more meaningful
docnames(corp_inaug) <- paste(dat_inaug$Year, 
                              dat_inaug$FirstName, 
                              dat_inaug$President, sep = " ")
summary(corp_inaug)


# Count number of documents in a corpus
ndoc(data_corpus_inaugural)

# Show first 5 documents in a corpus
head(docvars(data_corpus_inaugural), 5)


# -----------------------------
#   Subset corpus
# -----------------------------

# Select a subset of the corpus documents with year more than 1990
corp_recent <- corpus_subset(data_corpus_inaugural, Year >= 1990)
summary(corp_recent)

# Select a subset of the corpus documents with only Democratic Party presidents
corp_dem <- corpus_subset(data_corpus_inaugural, President %in% c('Obama', 'Clinton', 'Carter'))
summary(corp_dem)

# Select a random sample of documents
summary(corpus_sample(data_corpus_inaugural, 10, replace = FALSE))

# -----------------------------
#   Change unit of texts
# -----------------------------

## Changing the units of data
corpus_ukimmig <- corpus(data_char_ukimmig2010)
head(corpus_ukimmig)

# Change to the unit to sentences
corp_sent <- corpus_reshape(corpus_ukimmig, to = 'sentences')
head(corp_sent)

# Notice the difference between the results of "head" and "ndoc" functions

# Keep only sentences with 10 words or more
corp_longsent <- corpus_subset(corp_sent, ntoken(corp_sent) >= 10)
ndoc(corp_longsent)

# Change the unit back to documents
corp_documents_long <- corpus_reshape(corp_longsent, to = 'documents')
ndoc(corp_documents_long)
summary(corp_documents_long)


# -----------------------------
#   Extract tags from texts
# -----------------------------

# Using corpus_segment(), you can extract segments of texts and tags from documents. 
# This is particular useful when you analyze sections of documents or transcripts separately.

corp_tagged <- corpus(c("##INTRO This is the introduction.
                         ##DOC1 This is the first document.  Second sentence in Doc 1.
                         ##DOC3 Third document starts here.  End of third document.",
                        "##INTRO Document ##NUMBER Two starts before ##NUMBER Three."))
corp_sect <- corpus_segment(corp_tagged, pattern = "##*")
summary(corp_sect)

texts(corp_sect)
docvars(corp_sect)

cbind(texts(corp_sect), docvars(corp_sect))

# Identify speakers from the compus
corp_speeches <- corpus("Mr. Smith: Text.
                       Mrs. Jones: More text.
                       Mr. Smith: I'm speaking, again.")

corp_speakers <- corpus_segment(corp_speeches, pattern = "\\b[A-Z].+\\s[A-Z][a-z]+:", valuetype = "regex")
cbind(texts(corp_speakers), docvars(corp_speakers))

# You should use corpus_reshape() to split documents into sentences, 
# but you can do similar operations using corpus_segment() by setting pattern_position = "after".

corp <- corpus(c(d1 = "This, is a sentence?  You: come here.", 
                 d2 = "Yes, yes okay."))
corp_sent <- corpus_segment(corp, pattern = "\\p{P}", valuetype = "regex", 
                            extract_pattern = FALSE, pattern_position = "after")
texts(corp_sent)


#===============================
#   Tokens    
#===============================


# -----------------------------
#   Construct a tokens object
# -----------------------------

# "tokens()" segments texts in a corpus into
# tokens (words or sentences) by word boundaries.

corp_immig <- corpus(data_char_ukimmig2010)
toks_immig <- tokens(corp_immig)
head(toks_immig[[1]], 50)



# By default, tokens() only removes separators
# (typically whitespaces), but you can remove 
# punctuation and numbers.

toks_nopunct <- tokens(data_char_ukimmig2010, 
                       remove_punct = TRUE)
head(toks_nopunct[[1]], 50)


# -----------------------------
#   Keywords-in-context (kwic)
# -----------------------------

toks <- tokens(data_char_ukimmig2010)

# You can see how keywords are used in the actual 
# contexts in a concordance view produced by kwic().
kw_immig <- kwic(toks, pattern =  'immig*')
head(kw_immig, 10)


#kwic() also takes multiple keywords in a character vector.
kw_immig2 <- kwic(toks, pattern = c('ille*', 'migra*'))
head(kw_immig2, 10)


# With the window argument, you can specify the 
# number of words to be displayed around the keyword.
kw_immig3 <- kwic(toks, pattern = c('ille*', 'migra*'), window = 3)
head(kw_immig3, 10)

# If you want to find multi-word expressions, separate
# words by whitespace and wrap the character vector by 
# phrase().
kw_asylum <- kwic(toks, pattern = phrase('asylum seeker*'))
head(kw_asylum)

# Texts do not always appear nicely in your R console, 
# so you can use View() to see the keywords-in-context 
# in an interactive HTML table.
View(kw_asylum)


# -----------------------------
#   Select tokens            
# -----------------------------

# You can remove tokens that you are not interested 
# in using tokens_select(). Usually we remove function 
# words (grammatical words) that have little or no 
# substantive meaning in pre-processing. stopwords() 
# returns a pre-defined list of function words.
toks_nostop <- tokens_select(toks, pattern = stopwords('en'), selection = 'remove')
head(toks_nostop[[1]], 50)

# tokens_remove() is an alias to tokens_select(selection = 'remove').
# Therefore, the code above and below are equivalent.
tooks_nostop2 <- tokens_remove(toks, pattern = stopwords('en'))
head(tooks_nostop2[[1]], 50)

# Removal of tokens changes the lengths of documents, 
# but they remain the same if you set padding = TRUE. 
# This option is useful especially when you perform 
# positional analysis.
toks_nostop_pad <- tokens_remove(toks, 
                                 pattern = stopwords('en'), 
                                 padding = TRUE)
head(toks_nostop_pad[[1]], 50)


# -----------------------------
#   Compound Tokens            
# -----------------------------

library(quanteda)


txt <- "The United Kingdom is leaving the European Union."
toks <- tokens(txt, remove_punct = TRUE)
tokens_compound(toks, phrase(c("United Kingdom", "European Union")))

# There are several multi-word expressions 
# that are important in social scientific reserach.
toks <- tokens(data_char_ukimmig2010)
kw_multiword <- kwic(toks, pattern = phrase(c('asylum seeker*', 'british citizen*')))
head(kw_multiword, 10)


# To preserve these expressions in bag-of-word analysis, 
# you have to compound them using tokens_compound().
toks_comp <- tokens_compound(toks, pattern = phrase(c('asylum seeker*', 'british citizen*')))
kw_comp <- kwic(toks_comp, pattern = c('asylum_seeker*', 'british_citizen*'))
head(kw_comp, 10)



# -----------------------------
#   Lookup Dictionary            
# -----------------------------

library(quanteda)
library(newsmap)
toks <- tokens(data_char_ukimmig2010)

# Load the geographical dictionary from "newmap" package
# The geographical dictionary comprises of names of 
# countries and cities (and their demonyms) in a hierachical 
# structure ( which countries are nested in world regions
# and sub-regions).
dict_newsmap <- data_dictionary_newsmap_en
length(dict_newsmap)
names(dict_newsmap)
names(dict_newsmap[['AFRICA']])
dict_newsmap[['AFRICA']][['NORTH']]

# Note: a dictionary is specially classed named-vectors
# of chararcters


# The levels argument determines the keys to be recored
# in a resulting tokens object.
toks_region <- tokens_lookup(toks, 
                             dictionary = dict_newsmap, 
                             levels = 1)
head(toks_region)
dfm(toks_region)

# Lookup at country level
toks_country <- tokens_lookup(toks, 
                              dictionary = dict_newsmap, 
                              levels = 3)
head(toks_country)
dfm(toks_country)


kwic(toks, dict_newsmap['AFRICA'])


# You can define your own dictionary by passing
# a named list of characters to dictionary().

dict <- dictionary(list(refugee = c('refugee*', 'asylum*'),
                        worker = c('worker*', 'employee*')))
print(dict)

dict_toks <- tokens_lookup(toks, dictionary = dict)
head(dict_toks)

dfm(dict_toks)


#==============================#
#   Document-feature matrix    #
#==============================#

library(quanteda)

# -----------------------------
#   Construct a DFM
# -----------------------------

# dfm() constructs a document-feature matrix (DFM)
# from a tokens object.

toks_irish <- tokens(data_corpus_irishbudget2010, remove_punct = TRUE)
dfmat_irish <- dfm(toks_irish)


# If corpus is given to dfm(), it tokenizes texts
# internally with the same level of control through
# the remove_* arguments of tokens(). Therefore,
# the code above and below are equivalent.
dfmat_irish <- dfm(data_corpus_irishbudget2010, remove_punct = TRUE)

# You can get the number of documents and features
# ndoc() and nfeat().

ndoc(dfmat_irish)
nfeat(dfmat_irish)

# You can also obtain the names of documents and
# features by docnames() and featnames().

docnames(dfmat_irish)

head(featnames(dfmat_irish), 20)

# Just like normal matrices, you can userowSums()
# and colSums() to calculate marginals.

rowSums(dfmat_irish)

head(colSums(dfmat_irish), 10)

# The most frequent features can be found using
# topfeatures().

topfeatures(dfmat_irish, 10)



# -----------------------------
#   Select features            
# -----------------------------

library(quanteda)

dfmat_irish <- dfm(data_corpus_irishbudget2010, 
                   remove_punct = TRUE)
nfeat(dfmat_irish)

# You can select features from a DFM using
# dfm_select().

dfmat_irish_nostop <- dfm_select(dfmat_irish,
                                 pattern = stopwords('en'),
                                 selection = 'remove')
nfeat(dfmat_irish_nostop)

# dfm_remove() is an alias to dfm_select(selection
# = 'remove'). Therefore, the code above and
# below are equivalent.

dfmat_irish_nostop <- dfm_remove(dfmat_irish, 
                                 pattern = stopwords('en'))
nfeat(dfmat_irish_nostop)

# You can also select features based on the length
# of features.
dfmat_irish_long <- dfm_select(dfmat_irish, 
                               min_nchar = 5)
nfeat(dfmat_irish_long)

topfeatures(dfmat_irish_long, 10)

# While dfm_select() selects features based on
# patterns, dfm_trim() does this based on feature
# frequencies. If min_termfreq = 10, features that
# occur less than 10 times in the corpus are removed.
dfmat_irish_freq <- dfm_trim(dfmat_irish, min_termfreq = 10)
nfeat(dfmat_irish_freq)

# If max_docfreq = 0.1, features that occur in
# more than 10% of the documents are removed.

dfmat_irish_docfreq <- dfm_trim(dfmat_irish, 
                                max_docfreq = 0.1, 
                                docfreq_type = "prop")
nfeat(dfmat_irish_docfreq)
topfeatures(dfmat_irish_docfreq)

# -----------------------------
#   Look-up dictionary            
# -----------------------------
library(quanteda)

URL = "https://raw.githubusercontent.com/quanteda/tutorials.quanteda.io/master/content/dictionary/laver-garry.cat"
download.file(URL, "laver-garry.cat")

# laver-garry.cat is a Wordstat dictionary that
# contains political left-right ideology keywords
# (Laver and Garry 2000).
dict_lg <- dictionary(file = "laver-garry.cat")
head(dict_lg, 2)

# dfm_lookup() translates dictionary values to
# keys in a DFM.
dfmat_irish <- dfm(data_corpus_irishbudget2010, 
                  remove_punct = TRUE)

dfmat_irish_lg <- dfm_lookup(dfmat_irish, 
                             dictionary = dict_lg)

nfeat(dfmat_irish_lg)

# You can also pass a dictionary to dfm() to simplify
# your code. Therefore, the code above and below
# are equivalent.

dfmat_irish_lg <- dfm(data_corpus_irishbudget2010, 
                      dictionary = dict_lg, 
                      remove_punct = TRUE)

nfeat(dfmat_irish_lg)

# -----------------------------
#   Group documents         
# -----------------------------
library(quanteda)

dfmat_irish <- dfm(data_corpus_irishbudget2010)
ndoc(dfmat_irish)

head(colSums(dfmat_irish), 10)

head(rowSums(dfmat_irish), 10)


# dfm_group() merges documents based on a vector
# of variables names given to the groups argument. 
# In grouping documents, it takes the sums of
# feature frequencies.
dfmat_party <- dfm_group(dfmat_irish, groups = "party")

ndoc(dfmat_party)

head(rowSums(dfmat_party), 10)

# dfm_group() identifies document-level variables
# that are the same within groups and keeps them.

docvars(dfmat_party)

docvars(data_corpus_irishbudget2010)


# You can also use the groups argument in dfm()
# to simplify your code.

dfmat_party <- dfm(data_corpus_irishbudget2010, 
                   groups = "party")
ndoc(dfmat_party)


#==============================#
# Feature co-occurence matrix  #
#==============================#

library(quanteda)
library(quanteda.corpora)


# A feature co-occurrence matrix (FCM) records number 
# of co-occurances of tokens. This is a special object
# in quanteda, but behaves similarly to a DFM.

corp_news <- download('data_corpus_guardian')

# When a corpus is large, you have to select features
# of a DFM before constructing a FCM.

dfmat_news <- dfm(corp_news, remove = stopwords('en'), remove_punct = TRUE)
dfmat_news <- dfm_remove(dfmat_news, pattern = c('*-time', 'updated-*', 'gmt', 'bst'))
dfmat_news <- dfm_trim(dfmat_news, min_termfreq = 100)

topfeatures(dfmat_news)

nfeat(dfmat_news)

dim(dfmat_news)


# You can construct a FCM from a DFM or a tokens object
# using fcm().
fcmat_news <- fcm(dfmat_news)

dim(fcmat_news)

head(fcmat_news)

# topfeatures() returns the most frequntly co-occuring words.
topfeatures(fcmat_news)

# You can select features of a FCM using fcm_select().
feat <- names(topfeatures(fcmat_news, 50))

fcmat_news_select <- fcm_select(fcmat_news, pattern = feat)

dim(fcmat_news_select)

topfeatures(fcmat_news_select)


# A FCM can be used to train word embedding models
# with the text2vec package, or to visualize a semantic
# network with textplot_network().
size <- log(colSums(dfm_select(dfmat_news, feat)))
set.seed(144)
textplot_network(fcmat_news_select, 
                 min_freq = 0.8, 
                 vertex_size = size / max(size) * 3)



################################
#                              #
#     STATISTICAL ANALYSIS     #
#                              #
################################

library(quanteda)
library(quanteda.corpora)
library(ggplot2)

#==============================#
#  Simple Frequency Analysis   #
#==============================#

# Unlike topfeatures(), textstat_frequency() shows both
# term and document frequencies. You can also use the
# function to find the most frequent features within groups.

# Using the download() function from quanteda.corpora,
# you can retrieve a text corpus of tweets.

corp_tweets <- download(url = 'https://www.dropbox.com/s/846skn1i5elbnd2/data_corpus_sampletweets.rds?dl=1')

names(docvars(corp_tweets))

# We can analyse the most frequent hashtags using 
# select = "#*" when creating the dfm.

toks_tweets <- tokens(corp_tweets, remove_punct = TRUE) 

dfmat_tweets <- dfm(toks_tweets, select = "#*")

tstat_freq <- textstat_frequency(dfmat_tweets, n = 5, groups = "lang")

head(tstat_freq, 20)

# You can also plot the Twitter hashtag frequencies easily
# using ggplot().


ggplot(textstat_frequency(dfmat_tweets, n = 15),
       aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()

# Alternatively you can create a Wordcloud of the 100 most
# common tags.

set.seed(132)
textplot_wordcloud(dfmat_tweets, max_words = 100)

# It is possible to compare different groups within one
# Wordcloud. We first create a dummy variable that
# indicates whether a tweet was posted in English or
# a different language. Afterwards, we compare the most
# frequent hashtags of English and non-English tweets.

# create document-level variable indicating whether
# Tweet was in English or other language
docvars(corp_tweets, "dummy_english") <- 
  factor(ifelse(docvars(corp_tweets, "lang") == "English",
                "English",
                "Not English"))

# create a grouped dfm and compare groups
dfmat_corp_language <- dfm(corp_tweets, 
                           select = "#*", 
                           groups = "dummy_english")

# create worcloud
set.seed(132)
textplot_wordcloud(dfmat_corp_language, comparison = TRUE, max_words = 200)


#==============================#
# Lexical Diversity            #
#==============================#


# textstat_lexdiv() calcuates lexical diversity in various
# measures based on the number of unique types of tokens
# and the length of a document. It is useful for analysing
# speakers’ or writers’ linguistic skill, or complexity of
# ideas expressed in docume

toks_inaug <- tokens(data_corpus_inaugural)



types(toks_inaug)

length(toks_inaug[[1]]) / length(types(toks_inaug[[1]]))

rowSums(dfmat_inaug)[[1]]


dfmat_inaug <- dfm(toks_inaug, remove = stopwords('en'))

tstat_lexdiv <- textstat_lexdiv(dfmat_inaug)

head(tstat_lexdiv, 5)

# TTR stands for Type-Token ration

plot(tstat_lexdiv$TTR, 
     type = 'l', 
     xaxt = 'n', 
     xlab = NULL, 
     ylab = "TTR") + 
  grid() +
  axis(1, 
       at = seq_len(nrow(tstat_lexdiv)), 
       labels = docvars(dfmat_inaug, 'President'))


#==============================#
#   Doc or Feature Similarity  #
#==============================#

# textstat_dist() calcuates similarites of documents or
# features for various measures. Its output is compatible
# with R’s dist(), so hierachical clustering can be
# perfromed without any transformation.

toks_inaug <- tokens(data_corpus_inaugural)

dfmat_inaug <- dfm(toks_inaug, remove = stopwords('en'))

# Calcuate the R distance matrix
tstat_dist <- as.dist(textstat_dist(dfmat_inaug))

# Create hierarchical clustering based on distance matrix 
clust <- hclust(tstat_dist)

plot(clust, xlab = "Distance", ylab = NULL)


################################
#                              #
# Targeted dictionary analysis #
#                              #
################################

library(quanteda)
library(quanteda.corpora)
library(lubridate)

# Load the the Guardian corpus which contains 
# 6,000 news articles from 2012 to 2016.

corp_news <- download('data_corpus_guardian')
ndoc(corp_news)

# Extract new variables from date
docvars(corp_news, 'year') <- year(docvars(corp_news, 'date'))
docvars(corp_news, 'month') <- month(docvars(corp_news, 'date'))
docvars(corp_news, 'week') <- week(docvars(corp_news, 'date'))
head(docvars(corp_news), 5)

# Check how many documents per year
table(docvars(corp_news, 'year'))

# Select a subset of articles from 2016 onwards
corp_news <- corpus_subset(corp_news, year >= 2016)
ndoc(corp_news)

toks_news <- tokens(corp_news, remove_punct = TRUE)
head(toks_news, 1)

# You can use tokens_lookup() or dfm_looup() to 
# count dictionary values. quanteda contains 
# Lexicoder Sentiment Dictionary created by 
# Young and Soroka, so you can perfrom sentiment 
# analysis of English texts right away.
lengths(data_dictionary_LSD2015)

# Label the sentiment of tokens according to dictionary
toks_news_lsd <- tokens_lookup(toks_news, 
                               dictionary =  data_dictionary_LSD2015[1:2])
toks_news_lsd

# Create document-feature matrix from sentiments
dfmat_news_lsd <- dfm(toks_news_lsd)
head(dfmat_news_lsd)


# You can use tokens_select() with window argument
# to perform more targeted sentiment analysis.

eu <- c('EU', 'europ*', 'european union')

toks_eu <- tokens_keep(toks_news, 
                       pattern = phrase(eu), 
                       window = 10)

# Calculate the document-feature matrix 
# and group the counts by week
dfmat_eu_lsd <- dfm(toks_eu, 
                    dictionary = data_dictionary_LSD2015[1:2]) %>% 
  dfm_group(group = 'week', fill = TRUE) 


# Show the number of positive and negative sentiments by week
matplot(dfmat_eu_lsd, type = 'l', xaxt = 'n', lty = 1, ylab = 'Frequency')
grid()

axis(1, 
     seq_len(ndoc(dfmat_eu_lsd)), 
     ymd("2016-01-01") + weeks(seq_len(ndoc(dfmat_eu_lsd)) - 1))

legend('topleft', 
       col = 1:2, 
       legend = c('Negative', 'Positive'), 
       lty = 1, 
       bg = 'white')

# Count the total number of features for each week
n_eu <- ntoken(dfm(toks_eu, group = docvars(toks_eu, 'week')))
n_eu

# Plot the difference of positive and negative 
plot((dfmat_eu_lsd[,2] - dfmat_eu_lsd[,1]) / n_eu, 
     type = 'l', 
     ylab = 'Sentiment', 
     xlab = '', 
     xaxt = 'n')

axis(1, 
     seq_len(ndoc(dfmat_eu_lsd)), 
     ymd("2016-01-01") + weeks(seq_len(ndoc(dfmat_eu_lsd)) - 1))

grid()

abline(h = 0, lty = 2)


# Sentement analysis with respect to "immigration"

immig <- c('immig*', 'migra*')
toks_immig <- tokens_keep(toks_news, pattern = phrase(immig), window = 10)
dfmat_immig_lsd <- dfm_group(dfm(toks_immig, dictionary = data_dictionary_LSD2015[1:2]), 
                             group = 'week', fill = TRUE)
   

matplot(dfmat_immig_lsd, type = 'l', xaxt = 'n', lty = 1, ylab = 'Frequency')
grid()
axis(1, seq_len(ndoc(dfmat_immig_lsd)), ymd("2016-01-01") + weeks(seq_len(ndoc(dfmat_immig_lsd)) - 1))
legend('topleft', col = 1:2, legend = c('Negative', 'Positive'), lty = 1, bg = 'white')


##################################
#                                # 
#     Text classification        #
#                                #
##################################


library(quanteda)
library(quanteda.corpora)
library(caret)


# Load movies corpus
corp_movies <- data_corpus_movies
summary(corp_movies, 5)


# generate 1500 numbers without replacement
set.seed(300)
id_train <- sample(1:2000, 1500, replace = FALSE)
head(id_train, 10)


# create docvar with ID
docvars(corp_movies, "id_numeric") <- 1:ndoc(corp_movies)

# get training set
dfmat_training <- corpus_subset(corp_movies, id_numeric %in% id_train) %>%
  dfm(stem = TRUE)

# get test set (documents not in id_train)
dfmat_test <- corpus_subset(corp_movies, !id_numeric %in% id_train) %>%
  dfm(stem = TRUE)

# Next we train the naive Bayes classifier using textmodel_nb().

tmod_nb <- textmodel_nb(dfmat_training, docvars(dfmat_training, "Sentiment"))
summary(tmod_nb)


# Naive Bayes can only take features into 
# consideration that occur both in the training set
# and the test set, but we can make the features
# identical by passing training_dfm to dfm_match() as a pattern.

dfmat_matched <- dfm_match(dfmat_test, features = featnames(dfmat_training))

# Let’s inspect how well the classification worked.
actual_class <- docvars(dfmat_matched, "Sentiment")
predicted_class <- predict(tmod_nb, newdata = dfmat_matched)

# Create confusion matrix
tab_class <- table(actual_class, predicted_class)
tab_class

# We can use the function confusionMatrix() from the 
# caret package to assess the performance of the classification.

confusionMatrix(tab_class, mode = "everything")
