(ns newsfeed.api
  (:require [compojure.core :refer :all]
            [clojure.java.io :as io]
            [feedparser-clj.core :as feed]
            [clojure.data.json :as json]
            [org.httpkit.client :as http]
            [clojure.tools.logging :as log]
            [ring.util.response :refer :all]))

(def options {:timeout 1000
              :user-agent "Newsfeed"})

(def feed-urls [;;"https://news.ycombinator.com/rss"
                "http://www.martinfowler.com/feed.atom"
                "https://www.thoughtworks.com/rss/insights.xml"])

(defn- response-is-good?
  [response]
  (let [status (:status response)]
    (if (and (>= 200 status)
             (< status 300))
      true
      (do (log/warn "Feed returned bad status" status (get-in response [:opts :url]))))))

(defn get-feeds
  [urls]
  (->> urls
      (map #(http/get % options))
      (map deref)
      (filter response-is-good?)
      (map :body)))

(defn parse-feed
  [feed]
  (try (feed/parse-feed feed)
       (catch Exception e (log/warn e "Error parsing feed"))))

(defn get-sort-value
  [item]
  (if (not (nil? (:updated-date item)))
    (:updated-date item)
    (:published-date item)))

(defn combine-feeds
  [feeds]
  (reverse (sort-by get-sort-value (apply concat (map :entries feeds)))))

(defn process-feed
  [feed]
  (assoc-in feed [:entries] (map #(assoc-in % [:source] {:title (:title feed)
                                                         :link  (:link feed)
                                                         :image (:image feed)})
                                 (:entries feed))))


(defn fetch-parse-combine []
  (let [feeds (get-feeds feed-urls)]
    (->> feeds
         (map #(.getBytes %))
         (map clojure.java.io/input-stream)
         (map parse-feed)
         (map process-feed)
         (combine-feeds))))

(defn format-key-value
  [key value]
  (if (instance? java.util.Date value)
    (.format (java.text.SimpleDateFormat. "yyyy-MM-dd'T'HH:mm:ss.SSSZ") value)
    value))

(defn api-routes []
  (routes
    (GET "/feeds" [] (json/write-str {:entries (fetch-parse-combine)}
                                     :value-fn format-key-value))))
