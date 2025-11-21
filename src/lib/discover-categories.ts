import { getPopular, getTrending, discoverMoviesPage, discoverTvShowsPage } from '@/lib/tmdb';
import { fetchFeaturedBollywood, fetchFeaturedAnimated, fetchFeaturedKorean, fetchAllAdventure, fetchMedia, allShows, fetchFeaturedHollywood, fetchCartoonsByChannel, fetchFeaturedMindfucks } from '@/lib/featured-media';

const HOLLYWOOD_PARAMS = { with_original_language: 'en', region: 'US' };
const HOLLYWOOD_VOTE_COUNT = { 'vote_count.gte': '300' };
const HOLLYWOOD_POPULAR_VOTE_COUNT = { 'vote_count.gte': '150' };

type Fetcher = (page?: number) => Promise<any>;

export const discoverCategories: Record<string, { title: string; fetcher: Fetcher }> = {
    'top-weekly': {
        title: 'Trending Now',
        fetcher: (page = 1) => getTrending('all', 'week', page),
    },
    'latest-release': {
        title: 'Latest Release',
        fetcher: (page = 1) => discoverMoviesPage({ ...HOLLYWOOD_PARAMS, ...HOLLYWOOD_POPULAR_VOTE_COUNT, sort_by: 'primary_release_date.desc', 'primary_release_date.lte': new Date().toISOString().split('T')[0] }, page),
    },
    'featured-hollywood': {
        title: 'Featured Hollywood',
        fetcher: (page = 1) => fetchFeaturedHollywood(page),
    },
    'top-rated-hollywood-movies': {
        title: 'Top Rated Hollywood Movies',
        fetcher: (page = 1) => discoverMoviesPage({ ...HOLLYWOOD_PARAMS, ...HOLLYWOOD_VOTE_COUNT, sort_by: 'vote_average.desc' }, page),
    },
    'featured-bollywood': {
        title: 'Featured Bollywood',
        fetcher: (page = 1) => fetchFeaturedBollywood(page),
    },
    'featured-animated': {
        title: 'Featured Animated',
        fetcher: (page = 1) => fetchFeaturedAnimated(page),
    },
    'featured-korean': {
        title: 'Featured Korean Cinema',
        fetcher: (page = 1) => fetchFeaturedKorean(page),
    },
    'featured-adventure': {
        title: 'Adventure & Survival',
        fetcher: (page = 1) => fetchAllAdventure(page),
    },
    'mindfucks-movies': {
        title: 'Best Mindfucks',
        // Use OR (|) instead of AND (,)
        fetcher: (page = 1) => discoverMoviesPage({ 'sort_by': 'vote_average.desc', 'vote_count.gte': '200', 'with_genres': '9648|53|878', 'without_genres': '10751', 'include_adult': 'false' }, page),
    },
    'survival-docs': {
        title: 'The Survivalists: Pushing Human Limits',
        fetcher: (page = 1) => fetchMedia(allShows.survivalists, page),
    },
    'explorer-docs': {
        title: 'The Adventurers & Explorers: Journey to the Unknown',
        fetcher: (page = 1) => fetchMedia(allShows.adventurers, page),
    },
    'wildlife-docs': {
        title: 'The Wild Kingdom',
        fetcher: (page = 1) => fetchMedia(allShows['wild-kingdom'], page),
    },
    'competition-docs': {
        title: 'The Competition: Survival of the Fittest',
        fetcher: (page = 1) => fetchMedia(allShows.competition, page),
    },
    'expedition-docs': {
        title: 'Deep Dives: Ocean and Mountain Expeditions',
        fetcher: (page = 1) => fetchMedia(allShows.expeditions, page),
    },
    'popular-hindi-tv': {
        title: 'Popular Hindi TV Shows',
        fetcher: (page = 1) => discoverTvShowsPage({ with_original_language: 'hi', sort_by: 'popularity.desc', 'vote_count.gte': '5' }, page),
    },
    'top-rated-netflix': {
        title: 'Top Rated on Netflix',
        fetcher: (page = 1) => discoverMoviesPage({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', sort_by: 'vote_average.desc', 'vote_count.gte': '300' }, page),
    },
    'popular-animated-tv': {
        title: 'Popular Animated TV Shows',
        fetcher: (page = 1) => discoverTvShowsPage({ with_genres: '16,10751', sort_by: 'popularity.desc' }, page),
    },
    'popular-korean-tv': {
        title: 'Popular Korean TV Shows',
        fetcher: (page = 1) => discoverTvShowsPage({ with_original_language: 'ko', sort_by: 'popularity.desc', 'vote_count.gte': '10', include_adult: 'false' }, page),
    },
    'latest-bollywood': { title: 'Latest Bollywood Releases', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', sort_by: 'primary_release_date.desc', 'primary_release_date.lte': new Date().toISOString().split('T')[0] }, page) },
    'classics-bollywood': { title: 'Top-Rated Bollywood Classics', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', 'primary_release_date.lte': '2000-12-31', sort_by: 'vote_average.desc', 'vote_count.gte': '20' }, page) },
    'action-bollywood': { title: 'Action Bollywood', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', with_genres: '28' }, page) },
    'romance-bollywood': { title: 'Romantic Bollywood', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', with_genres: '10749' }, page) },
    'latest-korean-movies': { title: 'Latest Korean Releases', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'ko', sort_by: 'primary_release_date.desc', 'vote_count.gte': '10' }, page) },
    'top-rated-korean-movies': { title: 'Top-Rated Korean Movies', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'ko', sort_by: 'vote_average.desc', 'vote_count.gte': '20' }, page) },
    'cartoons-cn': { title: 'Cartoon Network', fetcher: (page=1) => fetchCartoonsByChannel('cartoon-network', page) },
    'cartoons-pogo': { title: 'Pogo', fetcher: (page=1) => fetchCartoonsByChannel('pogo', page) },
    'cartoons-nick': { title: 'Nickelodeon', fetcher: (page=1) => fetchCartoonsByChannel('nick', page) },
    'cartoons-disney': { title: 'Disney Channel', fetcher: (page=1) => fetchCartoonsByChannel('disney', page) },
};