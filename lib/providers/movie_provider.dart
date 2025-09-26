import 'package:flutter/foundation.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/tmdb_service.dart';
import 'package:movora/services/cache_service.dart';

class MovieProvider with ChangeNotifier {
  // Performance optimization: Use more efficient data structures
  final Map<String, List<Media>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 15);

  MovieProvider();

  // Simplified filtering - no adult content filtering needed
  List<Media> _filterAdultContent(List<Media> mediaList) {
    return mediaList; // Return all content without filtering
  }

  // Performance optimization: Cache genre names
  static const Map<int, String> _genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  // Helper method to get genre name from ID - now O(1) lookup
  String _getGenreName(int genreId) {
    return _genreMap[genreId] ?? 'Unknown';
  }

  // Performance optimization: Smart cache management
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheValidDuration;
  }

  // Performance optimization: Batch refresh with single notification
  Future<void> refreshAdultContentFilter() async {
    // Batch all filtering operations
    final operations = [
      () => _popularNow = _filterAdultContent(_popularNow),
      () => _newlyReleased = _filterAdultContent(_newlyReleased),
      () => _mostPopular = _filterAdultContent(_mostPopular),
      () => _topRatedMovies = _filterAdultContent(_topRatedMovies),
      () => _topRatedTvShows = _filterAdultContent(_topRatedTvShows),
      () => _actionAdventure = _filterAdultContent(_actionAdventure),
      () => _comedy = _filterAdultContent(_comedy),
      () => _scifiFantasy = _filterAdultContent(_scifiFantasy),
      () => _horror = _filterAdultContent(_horror),
      () => _thriller = _filterAdultContent(_thriller),
      () => _drama = _filterAdultContent(_drama),
      () => _romance = _filterAdultContent(_romance),
      () => _animation = _filterAdultContent(_animation),
      () => _family = _filterAdultContent(_family),
      () => _documentary = _filterAdultContent(_documentary),
      () => _crime = _filterAdultContent(_crime),
      () => _mystery = _filterAdultContent(_mystery),
      () => _war = _filterAdultContent(_war),
      () => _western = _filterAdultContent(_western),
      () => _music = _filterAdultContent(_music),
      () => _history = _filterAdultContent(_history),
      () => _upcoming = _filterAdultContent(_upcoming),
      () => _awardWinners = _filterAdultContent(_awardWinners),
      () => _indie = _filterAdultContent(_indie),
      () => _foreign = _filterAdultContent(_foreign),
      () => _classics = _filterAdultContent(_classics),
      () => _teen = _filterAdultContent(_teen),
    ];

    // Execute all operations
    for (final operation in operations) {
      operation();
    }

    // Single notification after all operations complete
    notifyListeners();

    // Re-filter Hollywood categories
    _superheroMovies = _filterAdultContent(_superheroMovies);
    _musicalMovies = _filterAdultContent(_musicalMovies);
    _sportsMovies = _filterAdultContent(_sportsMovies);
    _biographicalMovies = _filterAdultContent(_biographicalMovies);
    _spyThrillers = _filterAdultContent(_spyThrillers);

    // Re-filter Bollywood categories
    _latestBollywood = _filterAdultContent(_latestBollywood);
    _classicsBollywood = _filterAdultContent(_classicsBollywood);
    _netflixBollywood = _filterAdultContent(_netflixBollywood);
    _primeBollywood = _filterAdultContent(_primeBollywood);
    _actionBollywood = _filterAdultContent(_actionBollywood);
    _romanceBollywood = _filterAdultContent(_romanceBollywood);
    _thrillerBollywood = _filterAdultContent(_thrillerBollywood);
    _popularHindiTv = _filterAdultContent(_popularHindiTv);
    _topRatedHindiTv = _filterAdultContent(_topRatedHindiTv);

    // Also refresh data from TMDB with new filter settings
    await _refreshDataWithNewFilter();

    // Notify listeners that content has been filtered
    notifyListeners();
  }

  // Refresh data from TMDB with new adult filter settings
  Future<void> _refreshDataWithNewFilter() async {
    try {
      // Refresh main catalogue with new filter
      await loadCatalogue();

      // Refresh Hollywood catalogue with new filter
      await loadHollywoodCatalogue();

      // Refresh other catalogues as needed
      // This ensures fresh data is fetched with the new adult filter setting
    } catch (e) {
      print('Error refreshing data with new filter: $e');
    }
  }

  // Main catalogue categories
  List<Media> _popularNow = [];
  List<Media> _newlyReleased = [];
  List<Media> _mostPopular = [];
  List<Media> _topRatedMovies = [];
  List<Media> _topRatedTvShows = [];
  List<Media> _actionAdventure = [];
  List<Media> _comedy = [];
  List<Media> _scifiFantasy = [];
  List<Media> _horror = [];
  List<Media> _thriller = [];
  List<Media> _drama = [];
  List<Media> _romance = [];
  List<Media> _animation = [];
  List<Media> _family = [];
  List<Media> _documentary = [];
  List<Media> _crime = [];
  List<Media> _mystery = [];
  List<Media> _war = [];
  List<Media> _western = [];
  List<Media> _music = [];
  List<Media> _history = [];

  // Special curated categories
  List<Media> _upcoming = [];
  List<Media> _awardWinners = [];
  List<Media> _indie = [];
  List<Media> _foreign = [];
  List<Media> _classics = [];
  List<Media> _teen = [];

  // New Hollywood categories
  List<Media> _superheroMovies = [];
  List<Media> _musicalMovies = [];
  List<Media> _sportsMovies = [];
  List<Media> _biographicalMovies = [];
  List<Media> _spyThrillers = [];
  final List<Media> _disasterMovies = [];
  final List<Media> _heistMovies = [];
  final List<Media> _buddyMovies = [];
  final List<Media> _roadMovies = [];
  final List<Media> _comingOfAge = [];
  final List<Media> _periodDramas = [];
  final List<Media> _noirMovies = [];
  final List<Media> _cultClassics = [];
  final List<Media> _blockbusters = [];
  final List<Media> _arthouse = [];
  final List<Media> _foreignLanguage = [];
  final List<Media> _documentaryFeatures = [];
  final List<Media> _shortFilms = [];
  final List<Media> _experimental = [];
  final List<Media> _silentMovies = [];
  final List<Media> _remakes = [];
  final List<Media> _sequels = [];
  final List<Media> _prequels = [];
  final List<Media> _spinOffs = [];
  final List<Media> _franchiseMovies = [];

  // Bollywood categories
  List<Media> _latestBollywood = [];
  List<Media> _classicsBollywood = [];
  List<Media> _netflixBollywood = [];
  List<Media> _primeBollywood = [];
  List<Media> _actionBollywood = [];
  List<Media> _romanceBollywood = [];
  List<Media> _thrillerBollywood = [];
  List<Media> _popularHindiTv = [];
  List<Media> _topRatedHindiTv = [];

  // New Bollywood categories
  List<Media> _newReleasesBollywood = [];
  List<Media> _blockbusterHitsBollywood = [];
  List<Media> _criticallyAcclaimedBollywood = [];
  List<Media> _familyEntertainmentBollywood = [];
  List<Media> _comedyGoldBollywood = [];
  List<Media> _actionThrillersBollywood = [];
  List<Media> _romanticDramasBollywood = [];
  List<Media> _mysteryCrimeBollywood = [];
  List<Media> _biographicalBollywood = [];
  List<Media> _webSeriesBollywood = [];
  List<Media> _upcomingBollywood = [];
  List<Media> _awardWinnersBollywood = [];

  // Additional Bollywood categories
  List<Media> _masalaMovies = [];
  List<Media> _patrioticMovies = [];
  List<Media> _socialDramas = [];
  List<Media> _comedyDramas = [];
  List<Media> _actionComedies = [];
  final List<Media> _romanticComedies = [];
  final List<Media> _thrillerComedies = [];
  final List<Media> _familyDramas = [];
  final List<Media> _youthMovies = [];
  final List<Media> _womenCentric = [];
  final List<Media> _childrenMovies = [];

  // Indian Regional Language categories
  List<Media> _tamilMovies = [];
  List<Media> _teluguMovies = [];
  List<Media> _malayalamMovies = [];
  List<Media> _marathiMovies = [];
  List<Media> _bengaliMovies = [];

  // Indian Genre categories
  List<Media> _bollywoodMasala = [];
  List<Media> _southIndianAction = [];
  List<Media> _marathiCinema = [];

  // Indian Streaming Platform categories
  List<Media> _hotstarContent = [];
  List<Media> _sonyLIVContent = [];
  List<Media> _zee5Content = [];
  final List<Media> _festivalMovies = [];
  final List<Media> _regionalCinema = [];
  final List<Media> _parallelCinema = [];
  final List<Media> _commercialCinema = [];
  final List<Media> _artCinema = [];
  final List<Media> _documentaryBollywood = [];
  final List<Media> _shortFilmsBollywood = [];
  final List<Media> _webSeriesHindi = [];
  List<Media> _tvShowsHindi = [];
  List<Media> _realityShowsHindi = [];
  final List<Media> _gameShowsHindi = [];
  final List<Media> _talkShowsHindi = [];
  final List<Media> _varietyShowsHindi = [];
  final List<Media> _newsShowsHindi = [];
  final List<Media> _educationalShowsHindi = [];

  // Korean categories
  List<Media> _latestKorean = [];
  List<Media> _topRatedKorean = [];
  List<Media> _actionKorean = [];
  List<Media> _thrillerKorean = [];
  List<Media> _popularKoreanTv = [];
  List<Media> _topRatedKoreanTv = [];
  List<Media> _featuredKorean = [];

  // New Korean categories
  List<Media> _newReleasesKorean = [];
  List<Media> _blockbusterHitsKorean = [];
  List<Media> _criticallyAcclaimedKorean = [];
  List<Media> _familyEntertainmentKorean = [];
  List<Media> _comedyGoldKorean = [];
  List<Media> _romanticDramasKorean = [];
  List<Media> _mysteryCrimeKorean = [];
  List<Media> _biographicalKorean = [];
  List<Media> _webSeriesKorean = [];
  List<Media> _upcomingKorean = [];
  List<Media> _awardWinnersKorean = [];
  List<Media> _koreanClassics = [];

  // Netflix categories
  List<Media> _topRatedNetflix = [];
  List<Media> _actionNetflix = [];
  List<Media> _comedyNetflix = [];
  List<Media> _dramaNetflix = [];
  List<Media> _thrillerNetflix = [];
  List<Media> _horrorNetflix = [];
  List<Media> _scifiNetflix = [];
  List<Media> _newReleasesNetflix = [];
  List<Media> _popularNetflix = [];
  List<Media> _awardWinnersNetflix = [];
  List<Media> _familyContentNetflix = [];
  List<Media> _romanceNetflix = [];
  List<Media> _mysteryNetflix = [];
  List<Media> _crimeNetflix = [];
  List<Media> _animationNetflix = [];
  List<Media> _documentaryNetflix = [];
  List<Media> _internationalNetflix = [];
  List<Media> _classicNetflix = [];
  List<Media> _upcomingNetflix = [];
  List<Media> _criticallyAcclaimedNetflix = [];

  // Prime categories
  List<Media> _topRatedPrime = [];
  List<Media> _actionPrime = [];
  List<Media> _comedyPrime = [];
  List<Media> _dramaPrime = [];
  List<Media> _thrillerPrime = [];
  List<Media> _scifiPrime = [];
  List<Media> _romancePrime = [];
  List<Media> _popularTvPrime = [];
  List<Media> _comedyTvPrime = [];
  List<Media> _dramaTvPrime = [];
  List<Media> _newReleasesPrime = [];
  List<Media> _popularPrime = [];
  List<Media> _awardWinnersPrime = [];
  List<Media> _familyContentPrime = [];
  List<Media> _mysteryPrime = [];
  List<Media> _crimePrime = [];
  List<Media> _animationPrime = [];
  List<Media> _documentaryPrime = [];
  List<Media> _internationalPrime = [];
  List<Media> _classicPrime = [];
  List<Media> _upcomingPrime = [];
  List<Media> _criticallyAcclaimedPrime = [];
  List<Media> _horrorPrime = [];
  List<Media> _warPrime = [];
  List<Media> _westernPrime = [];
  List<Media> _musicalPrime = [];
  List<Media> _biographicalPrime = [];
  List<Media> _sportsPrime = [];
  List<Media> _adventurePrime = [];
  List<Media> _fantasyPrime = [];
  List<Media> _superheroPrime = [];
  List<Media> _indiePrime = [];
  List<Media> _foreignPrime = [];
  List<Media> _teenPrime = [];
  List<Media> _kidsPrime = [];
  List<Media> _realityTvPrime = [];
  List<Media> _gameShowPrime = [];
  List<Media> _talkShowPrime = [];
  List<Media> _varietyPrime = [];
  List<Media> _newsPrime = [];
  List<Media> _educationalPrime = [];

  // Top 250 categories

  // Animated categories
  List<Media> _topRatedAnimated = [];
  List<Media> _pixarAnimated = [];
  List<Media> _ghibliAnimated = [];
  List<Media> _recentUpcomingAnimated = [];
  List<Media> _popularAnimatedTv = [];
  List<Media> _newReleasesAnimated = [];
  List<Media> _popularAnimated = [];
  List<Media> _awardWinnersAnimated = [];
  List<Media> _familyAnimated = [];
  List<Media> _comedyAnimated = [];
  List<Media> _adventureAnimated = [];
  List<Media> _fantasyAnimated = [];
  List<Media> _superheroAnimated = [];
  List<Media> _musicalAnimated = [];
  List<Media> _classicAnimated = [];
  List<Media> _upcomingAnimated = [];
  List<Media> _criticallyAcclaimedAnimated = [];
  List<Media> _indieAnimated = [];
  List<Media> _foreignAnimated = [];
  List<Media> _teenAnimated = [];
  List<Media> _kidsAnimated = [];
  List<Media> _stopMotionAnimated = [];
  List<Media> _computerGeneratedAnimated = [];
  List<Media> _handDrawnAnimated = [];
  List<Media> _animeAnimated = [];
  List<Media> _europeanAnimated = [];
  List<Media> _disneyAnimated = [];
  List<Media> _dreamworksAnimated = [];
  List<Media> _illuminationAnimated = [];
  List<Media> _sonyAnimated = [];
  List<Media> _warnerAnimated = [];
  List<Media> _paramountAnimated = [];
  List<Media> _universalAnimated = [];
  List<Media> _foxAnimated = [];
  List<Media> _mangaAnimated = [];
  List<Media> _cartoonNetworkAnimated = [];
  List<Media> _nickelodeonAnimated = [];
  List<Media> _disneyChannelAnimated = [];
  List<Media> _netflixAnimated = [];
  List<Media> _primeAnimated = [];
  List<Media> _huluAnimated = [];
  List<Media> _hboAnimated = [];
  List<Media> _appleAnimated = [];
  List<Media> _peacockAnimated = [];
  List<Media> _paramountPlusAnimated = [];
  List<Media> _disneyPlusAnimated = [];
  List<Media> _maxAnimated = [];

  // Mindfucks categories

  // Documentaries categories
  List<Media> _topRatedDocumentaries = [];
  List<Media> _recentDocumentaries = [];
  List<Media> _bioDocumentaries = [];
  List<Media> _netflixDocumentaries = [];
  List<Media> _primeDocumentaries = [];
  List<Media> _popularDocuseries = [];

  // Search results
  List<Media> _searchResults = [];

  // Loading states
  bool _isLoadingPopular = false;
  bool _isLoadingNewlyReleased = false;
  bool _isLoadingMostPopular = false;
  bool _isLoadingTopRatedMovies = false;
  bool _isLoadingTopRatedTvShows = false;
  bool _isLoadingActionAdventure = false;
  bool _isLoadingComedy = false;
  bool _isLoadingScifiFantasy = false;
  bool _isLoadingHorror = false;
  bool _isLoadingThriller = false;
  bool _isLoadingDrama = false;
  bool _isLoadingRomance = false;
  bool _isLoadingAnimation = false;
  bool _isLoadingFamily = false;
  bool _isLoadingDocumentary = false;
  bool _isLoadingCrime = false;
  bool _isLoadingMystery = false;
  bool _isLoadingWar = false;
  bool _isLoadingWestern = false;
  bool _isLoadingMusic = false;
  bool _isLoadingHistory = false;
  bool _isSearching = false;

  // New Hollywood loading states
  bool _isLoadingSuperheroMovies = false;
  bool _isLoadingMusicalMovies = false;
  bool _isLoadingSportsMovies = false;
  bool _isLoadingBiographicalMovies = false;
  bool _isLoadingSpyThrillers = false;
  final bool _isLoadingDisasterMovies = false;
  final bool _isLoadingHeistMovies = false;
  final bool _isLoadingBuddyMovies = false;
  final bool _isLoadingRoadMovies = false;
  final bool _isLoadingComingOfAge = false;
  final bool _isLoadingPeriodDramas = false;
  final bool _isLoadingNoirMovies = false;
  final bool _isLoadingCultClassics = false;
  final bool _isLoadingBlockbusters = false;
  final bool _isLoadingArthouse = false;
  final bool _isLoadingForeignLanguage = false;
  final bool _isLoadingDocumentaryFeatures = false;
  final bool _isLoadingShortFilms = false;
  final bool _isLoadingExperimental = false;
  final bool _isLoadingSilentMovies = false;
  final bool _isLoadingRemakes = false;
  final bool _isLoadingSequels = false;
  final bool _isLoadingPrequels = false;
  final bool _isLoadingSpinOffs = false;
  final bool _isLoadingFranchiseMovies = false;

  // Bollywood loading states
  bool _isLoadingLatestBollywood = false;
  bool _isLoadingClassicsBollywood = false;
  bool _isLoadingNetflixBollywood = false;
  bool _isLoadingPrimeBollywood = false;
  bool _isLoadingActionBollywood = false;
  bool _isLoadingRomanceBollywood = false;
  bool _isLoadingThrillerBollywood = false;
  bool _isLoadingPopularHindiTv = false;
  bool _isLoadingTopRatedHindiTv = false;

  // New Bollywood loading states
  bool _isLoadingNewReleasesBollywood = false;
  bool _isLoadingBlockbusterHitsBollywood = false;
  bool _isLoadingCriticallyAcclaimedBollywood = false;
  bool _isLoadingFamilyEntertainmentBollywood = false;
  bool _isLoadingComedyGoldBollywood = false;
  bool _isLoadingActionThrillersBollywood = false;
  bool _isLoadingRomanticDramasBollywood = false;
  bool _isLoadingMysteryCrimeBollywood = false;
  bool _isLoadingBiographicalBollywood = false;
  bool _isLoadingWebSeriesBollywood = false;
  bool _isLoadingUpcomingBollywood = false;
  bool _isLoadingAwardWinnersBollywood = false;

  // Additional Bollywood loading states
  bool _isLoadingMasalaMovies = false;
  bool _isLoadingPatrioticMovies = false;
  bool _isLoadingSocialDramas = false;
  bool _isLoadingComedyDramas = false;
  bool _isLoadingActionComedies = false;
  final bool _isLoadingRomanticComedies = false;
  final bool _isLoadingThrillerComedies = false;
  final bool _isLoadingFamilyDramas = false;
  final bool _isLoadingYouthMovies = false;
  final bool _isLoadingWomenCentric = false;
  final bool _isLoadingChildrenMovies = false;
  final bool _isLoadingFestivalMovies = false;
  final bool _isLoadingRegionalCinema = false;
  final bool _isLoadingParallelCinema = false;
  final bool _isLoadingCommercialCinema = false;
  final bool _isLoadingArtCinema = false;
  final bool _isLoadingDocumentaryBollywood = false;
  final bool _isLoadingShortFilmsBollywood = false;

  // Indian Regional Language loading states
  bool _isLoadingTamilMovies = false;
  bool _isLoadingTeluguMovies = false;
  bool _isLoadingMalayalamMovies = false;
  bool _isLoadingMarathiMovies = false;
  bool _isLoadingBengaliMovies = false;

  // Indian Genre loading states
  bool _isLoadingBollywoodMasala = false;
  bool _isLoadingSouthIndianAction = false;
  bool _isLoadingMarathiCinema = false;

  // Indian Streaming Platform loading states
  bool _isLoadingHotstarContent = false;
  bool _isLoadingSonyLIVContent = false;
  bool _isLoadingZee5Content = false;
  final bool _isLoadingWebSeriesHindi = false;
  bool _isLoadingTvShowsHindi = false;
  bool _isLoadingRealityShowsHindi = false;
  final bool _isLoadingGameShowsHindi = false;
  final bool _isLoadingTalkShowsHindi = false;
  final bool _isLoadingVarietyShowsHindi = false;
  final bool _isLoadingNewsShowsHindi = false;
  final bool _isLoadingEducationalShowsHindi = false;

  // Korean loading states
  bool _isLoadingLatestKorean = false;
  bool _isLoadingTopRatedKorean = false;
  bool _isLoadingActionKorean = false;
  bool _isLoadingThrillerKorean = false;
  bool _isLoadingPopularKoreanTv = false;
  bool _isLoadingTopRatedKoreanTv = false;
  bool _isLoadingFeaturedKorean = false;

  // New Korean loading states
  bool _isLoadingNewReleasesKorean = false;
  bool _isLoadingBlockbusterHitsKorean = false;
  bool _isLoadingCriticallyAcclaimedKorean = false;
  bool _isLoadingFamilyEntertainmentKorean = false;
  bool _isLoadingComedyGoldKorean = false;
  bool _isLoadingRomanticDramasKorean = false;
  bool _isLoadingMysteryCrimeKorean = false;
  bool _isLoadingBiographicalKorean = false;
  bool _isLoadingWebSeriesKorean = false;
  bool _isLoadingUpcomingKorean = false;
  bool _isLoadingAwardWinnersKorean = false;
  bool _isLoadingKoreanClassics = false;

  // Netflix loading states
  bool _isLoadingTopRatedNetflix = false;
  bool _isLoadingActionNetflix = false;
  bool _isLoadingComedyNetflix = false;
  bool _isLoadingDramaNetflix = false;
  bool _isLoadingThrillerNetflix = false;
  bool _isLoadingHorrorNetflix = false;
  bool _isLoadingScifiNetflix = false;
  bool _isLoadingNewReleasesNetflix = false;
  bool _isLoadingPopularNetflix = false;
  bool _isLoadingAwardWinnersNetflix = false;
  bool _isLoadingFamilyContentNetflix = false;
  bool _isLoadingRomanceNetflix = false;
  bool _isLoadingMysteryNetflix = false;
  bool _isLoadingCrimeNetflix = false;
  bool _isLoadingAnimationNetflix = false;
  bool _isLoadingDocumentaryNetflix = false;
  bool _isLoadingInternationalNetflix = false;
  bool _isLoadingClassicNetflix = false;
  bool _isLoadingUpcomingNetflix = false;
  bool _isLoadingCriticallyAcclaimedNetflix = false;

  // Prime loading states
  bool _isLoadingTopRatedPrime = false;
  bool _isLoadingActionPrime = false;
  bool _isLoadingComedyPrime = false;
  bool _isLoadingDramaPrime = false;
  bool _isLoadingThrillerPrime = false;
  bool _isLoadingScifiPrime = false;
  bool _isLoadingRomancePrime = false;
  bool _isLoadingPopularTvPrime = false;
  bool _isLoadingComedyTvPrime = false;
  bool _isLoadingDramaTvPrime = false;
  bool _isLoadingNewReleasesPrime = false;
  bool _isLoadingPopularPrime = false;
  bool _isLoadingAwardWinnersPrime = false;
  bool _isLoadingFamilyContentPrime = false;
  bool _isLoadingMysteryPrime = false;
  bool _isLoadingCrimePrime = false;
  bool _isLoadingAnimationPrime = false;
  bool _isLoadingDocumentaryPrime = false;
  bool _isLoadingInternationalPrime = false;
  bool _isLoadingClassicPrime = false;
  bool _isLoadingUpcomingPrime = false;
  bool _isLoadingCriticallyAcclaimedPrime = false;
  bool _isLoadingHorrorPrime = false;
  bool _isLoadingWarPrime = false;
  bool _isLoadingWesternPrime = false;
  bool _isLoadingMusicalPrime = false;
  bool _isLoadingBiographicalPrime = false;
  bool _isLoadingSportsPrime = false;
  bool _isLoadingAdventurePrime = false;
  bool _isLoadingFantasyPrime = false;
  bool _isLoadingSuperheroPrime = false;
  bool _isLoadingIndiePrime = false;
  bool _isLoadingForeignPrime = false;
  bool _isLoadingTeenPrime = false;
  bool _isLoadingKidsPrime = false;
  bool _isLoadingRealityTvPrime = false;
  bool _isLoadingGameShowPrime = false;
  bool _isLoadingTalkShowPrime = false;
  bool _isLoadingVarietyPrime = false;
  bool _isLoadingNewsPrime = false;
  bool _isLoadingEducationalPrime = false;

  // Top 250 loading states

  // Animated loading states
  bool _isLoadingTopRatedAnimated = false;
  bool _isLoadingPixarAnimated = false;
  bool _isLoadingGhibliAnimated = false;
  bool _isLoadingRecentUpcomingAnimated = false;
  bool _isLoadingPopularAnimatedTv = false;
  bool _isLoadingNewReleasesAnimated = false;
  bool _isLoadingPopularAnimated = false;
  bool _isLoadingAwardWinnersAnimated = false;
  bool _isLoadingFamilyAnimated = false;
  bool _isLoadingComedyAnimated = false;
  bool _isLoadingAdventureAnimated = false;
  bool _isLoadingFantasyAnimated = false;
  bool _isLoadingSuperheroAnimated = false;
  bool _isLoadingMusicalAnimated = false;
  bool _isLoadingClassicAnimated = false;
  bool _isLoadingUpcomingAnimated = false;
  bool _isLoadingCriticallyAcclaimedAnimated = false;
  bool _isLoadingIndieAnimated = false;
  bool _isLoadingForeignAnimated = false;
  bool _isLoadingTeenAnimated = false;
  bool _isLoadingKidsAnimated = false;
  bool _isLoadingStopMotionAnimated = false;
  bool _isLoadingComputerGeneratedAnimated = false;
  bool _isLoadingHandDrawnAnimated = false;
  bool _isLoadingAnimeAnimated = false;
  bool _isLoadingEuropeanAnimated = false;
  bool _isLoadingDisneyAnimated = false;
  bool _isLoadingDreamworksAnimated = false;
  bool _isLoadingIlluminationAnimated = false;
  bool _isLoadingSonyAnimated = false;
  bool _isLoadingWarnerAnimated = false;
  bool _isLoadingParamountAnimated = false;
  bool _isLoadingUniversalAnimated = false;
  bool _isLoadingFoxAnimated = false;
  bool _isLoadingMangaAnimated = false;
  bool _isLoadingCartoonNetworkAnimated = false;
  bool _isLoadingNickelodeonAnimated = false;
  bool _isLoadingDisneyChannelAnimated = false;
  bool _isLoadingNetflixAnimated = false;
  bool _isLoadingPrimeAnimated = false;
  bool _isLoadingHuluAnimated = false;
  bool _isLoadingHboAnimated = false;
  bool _isLoadingAppleAnimated = false;
  bool _isLoadingPeacockAnimated = false;
  bool _isLoadingParamountPlusAnimated = false;
  bool _isLoadingDisneyPlusAnimated = false;
  bool _isLoadingMaxAnimated = false;

  // Mindfucks loading states

  // Indian Cartoons loading states

  // Documentaries loading states
  bool _isLoadingTopRatedDocumentaries = false;
  bool _isLoadingRecentDocumentaries = false;
  bool _isLoadingBioDocumentaries = false;
  bool _isLoadingNetflixDocumentaries = false;
  bool _isLoadingPrimeDocumentaries = false;
  bool _isLoadingPopularDocuseries = false;

  // Adventure loading states

  // Error states
  String? _popularError;
  String? _newlyReleasedError;
  String? _mostPopularError;
  String? _topRatedMoviesError;
  String? _topRatedTvShowsError;
  String? _actionAdventureError;
  String? _comedyError;
  String? _scifiFantasyError;
  String? _horrorError;
  String? _thrillerError;
  String? _dramaError;
  String? _romanceError;
  String? _animationError;
  String? _familyError;
  String? _documentaryError;
  String? _crimeError;
  String? _mysteryError;
  String? _warError;
  String? _westernError;
  String? _musicError;
  String? _historyError;
  String? _searchError;

  // Bollywood error states
  String? _latestBollywoodError;
  String? _classicsBollywoodError;
  String? _netflixBollywoodError;
  String? _primeBollywoodError;
  String? _actionBollywoodError;
  String? _romanceBollywoodError;
  String? _thrillerBollywoodError;
  String? _popularHindiTvError;
  String? _topRatedHindiTvError;

  // New Bollywood error states
  String? _newReleasesBollywoodError;
  String? _blockbusterHitsBollywoodError;
  String? _criticallyAcclaimedBollywoodError;
  String? _familyEntertainmentBollywoodError;
  String? _comedyGoldBollywoodError;
  String? _actionThrillersBollywoodError;
  String? _romanticDramasBollywoodError;
  String? _mysteryCrimeBollywoodError;
  String? _biographicalBollywoodError;
  String? _webSeriesBollywoodError;
  String? _upcomingBollywoodError;
  String? _awardWinnersBollywoodError;

  // Korean error states
  String? _latestKoreanError;
  String? _topRatedKoreanError;
  String? _actionKoreanError;
  String? _thrillerKoreanError;
  String? _popularKoreanTvError;
  String? _topRatedKoreanTvError;
  String? _featuredKoreanError;

  // Indian Regional Language error states
  String? _tamilMoviesError;
  String? _teluguMoviesError;
  String? _malayalamMoviesError;
  String? _marathiMoviesError;
  String? _bengaliMoviesError;

  // Indian Genre error states
  String? _bollywoodMasalaError;
  String? _southIndianActionError;
  String? _marathiCinemaError;

  // Indian Streaming Platform error states
  String? _hotstarContentError;
  String? _sonyLIVContentError;
  String? _zee5ContentError;

  // New Korean error states
  String? _newReleasesKoreanError;
  String? _blockbusterHitsKoreanError;
  String? _criticallyAcclaimedKoreanError;
  String? _familyEntertainmentKoreanError;
  String? _comedyGoldKoreanError;
  String? _romanticDramasKoreanError;
  String? _mysteryCrimeKoreanError;
  String? _biographicalKoreanError;
  String? _webSeriesKoreanError;
  String? _upcomingKoreanError;
  String? _awardWinnersKoreanError;
  String? _koreanClassicsError;

  // Netflix error states
  String? _topRatedNetflixError;
  String? _actionNetflixError;
  String? _comedyNetflixError;
  String? _dramaNetflixError;
  String? _thrillerNetflixError;
  String? _horrorNetflixError;
  String? _scifiNetflixError;
  String? _newReleasesNetflixError;
  String? _popularNetflixError;
  String? _awardWinnersNetflixError;
  String? _familyContentNetflixError;
  String? _romanceNetflixError;
  String? _mysteryNetflixError;
  String? _crimeNetflixError;
  String? _animationNetflixError;
  String? _documentaryNetflixError;
  String? _internationalNetflixError;
  String? _classicNetflixError;
  String? _upcomingNetflixError;
  String? _criticallyAcclaimedNetflixError;

  // Prime error states
  String? _topRatedPrimeError;
  String? _actionPrimeError;
  String? _comedyPrimeError;
  String? _dramaPrimeError;
  String? _thrillerPrimeError;
  String? _scifiPrimeError;
  String? _romancePrimeError;
  String? _popularTvPrimeError;
  String? _comedyTvPrimeError;
  String? _dramaTvPrimeError;
  String? _newReleasesPrimeError;
  String? _popularPrimeError;
  String? _awardWinnersPrimeError;
  String? _familyContentPrimeError;
  String? _mysteryPrimeError;
  String? _crimePrimeError;
  String? _animationPrimeError;
  String? _documentaryPrimeError;
  String? _internationalPrimeError;
  String? _classicPrimeError;
  String? _upcomingPrimeError;
  String? _criticallyAcclaimedPrimeError;
  String? _horrorPrimeError;
  String? _warPrimeError;
  String? _westernPrimeError;
  String? _musicalPrimeError;
  String? _biographicalPrimeError;
  String? _sportsPrimeError;
  String? _adventurePrimeError;
  String? _fantasyPrimeError;
  String? _superheroPrimeError;
  String? _indiePrimeError;
  String? _foreignPrimeError;
  String? _teenPrimeError;
  String? _kidsPrimeError;
  String? _realityTvPrimeError;
  String? _gameShowPrimeError;
  String? _talkShowPrimeError;
  String? _varietyPrimeError;
  String? _newsPrimeError;
  String? _educationalPrimeError;

  // Top 250 error states

  // Animated error states
  String? _topRatedAnimatedError;
  String? _pixarAnimatedError;
  String? _ghibliAnimatedError;
  String? _recentUpcomingAnimatedError;
  String? _popularAnimatedTvError;
  String? _newReleasesAnimatedError;
  String? _popularAnimatedError;
  String? _awardWinnersAnimatedError;
  String? _familyAnimatedError;
  String? _comedyAnimatedError;
  String? _adventureAnimatedError;
  String? _fantasyAnimatedError;
  String? _superheroAnimatedError;
  String? _musicalAnimatedError;
  String? _classicAnimatedError;
  String? _upcomingAnimatedError;
  String? _criticallyAcclaimedAnimatedError;
  String? _indieAnimatedError;
  String? _foreignAnimatedError;
  String? _teenAnimatedError;
  String? _kidsAnimatedError;
  String? _stopMotionAnimatedError;
  String? _computerGeneratedAnimatedError;
  String? _handDrawnAnimatedError;
  String? _animeAnimatedError;
  String? _europeanAnimatedError;
  String? _disneyAnimatedError;
  String? _dreamworksAnimatedError;
  String? _illuminationAnimatedError;
  String? _sonyAnimatedError;
  String? _warnerAnimatedError;
  String? _paramountAnimatedError;
  String? _universalAnimatedError;
  String? _foxAnimatedError;
  String? _mangaAnimatedError;
  String? _cartoonNetworkAnimatedError;
  String? _nickelodeonAnimatedError;
  String? _disneyChannelAnimatedError;
  String? _netflixAnimatedError;
  String? _primeAnimatedError;
  String? _huluAnimatedError;
  String? _hboAnimatedError;
  String? _appleAnimatedError;
  String? _peacockAnimatedError;
  String? _paramountPlusAnimatedError;
  String? _disneyPlusAnimatedError;
  String? _maxAnimatedError;

  // Mindfucks error states

  // Indian Cartoons error states

  // Documentaries error states
  String? _topRatedDocumentariesError;
  String? _recentDocumentariesError;
  String? _bioDocumentariesError;
  String? _netflixDocumentariesError;
  String? _primeDocumentariesError;
  String? _popularDocuseriesError;

  // Adventure error states
  String? _adventureError;

  // Special curated loading states
  bool _isLoadingUpcoming = false;
  bool _isLoadingAwardWinners = false;
  bool _isLoadingIndie = false;
  bool _isLoadingForeign = false;
  bool _isLoadingClassics = false;
  bool _isLoadingTeen = false;

  // Special curated error states
  String? _upcomingError;
  String? _awardWinnersError;
  String? _indieError;
  String? _foreignError;
  String? _classicsError;
  String? _teenError;

  // Getters
  List<Media> get popularNow => _popularNow;
  List<Media> get newlyReleased => _newlyReleased;
  List<Media> get mostPopular => _mostPopular;
  List<Media> get topRatedMovies => _topRatedMovies;
  List<Media> get topRatedTvShows => _topRatedTvShows;
  List<Media> get actionAdventure => _actionAdventure;
  List<Media> get comedy => _comedy;
  List<Media> get scifiFantasy => _scifiFantasy;
  List<Media> get horror => _horror;
  List<Media> get thriller => _thriller;
  List<Media> get drama => _drama;
  List<Media> get romance => _romance;
  List<Media> get animation => _animation;
  List<Media> get family => _family;
  List<Media> get documentary => _documentary;
  List<Media> get crime => _crime;
  List<Media> get mystery => _mystery;
  List<Media> get war => _war;
  List<Media> get western => _western;
  List<Media> get music => _music;
  List<Media> get history => _history;

  // Special curated getters
  List<Media> get upcoming => _upcoming;
  List<Media> get awardWinners => _awardWinners;
  List<Media> get indie => _indie;
  List<Media> get foreign => _foreign;
  List<Media> get classics => _classics;
  List<Media> get teen => _teen;

  // New Hollywood getters
  List<Media> get superheroMovies => _superheroMovies;
  List<Media> get musicalMovies => _musicalMovies;
  List<Media> get sportsMovies => _sportsMovies;
  List<Media> get biographicalMovies => _biographicalMovies;
  List<Media> get spyThrillers => _spyThrillers;
  List<Media> get disasterMovies => _disasterMovies;
  List<Media> get heistMovies => _heistMovies;
  List<Media> get buddyMovies => _buddyMovies;
  List<Media> get roadMovies => _roadMovies;
  List<Media> get comingOfAge => _comingOfAge;
  List<Media> get periodDramas => _periodDramas;
  List<Media> get noirMovies => _noirMovies;
  List<Media> get cultClassics => _cultClassics;
  List<Media> get blockbusters => _blockbusters;
  List<Media> get arthouse => _arthouse;
  List<Media> get foreignLanguage => _foreignLanguage;
  List<Media> get documentaryFeatures => _documentaryFeatures;
  List<Media> get shortFilms => _shortFilms;
  List<Media> get experimental => _experimental;
  List<Media> get silentMovies => _silentMovies;
  List<Media> get remakes => _remakes;
  List<Media> get sequels => _sequels;
  List<Media> get prequels => _prequels;
  List<Media> get spinOffs => _spinOffs;
  List<Media> get franchiseMovies => _franchiseMovies;

  List<Media> get searchResults => _searchResults;

  // Bollywood getters
  List<Media> get latestBollywood => _latestBollywood;
  List<Media> get classicsBollywood => _classicsBollywood;
  List<Media> get netflixBollywood => _netflixBollywood;
  List<Media> get primeBollywood => _primeBollywood;
  List<Media> get actionBollywood => _actionBollywood;
  List<Media> get romanceBollywood => _romanceBollywood;
  List<Media> get thrillerBollywood => _thrillerBollywood;
  List<Media> get popularHindiTv => _popularHindiTv;
  List<Media> get topRatedHindiTv => _topRatedHindiTv;

  // New Bollywood getters
  List<Media> get newReleasesBollywood => _newReleasesBollywood;
  List<Media> get blockbusterHitsBollywood => _blockbusterHitsBollywood;
  List<Media> get criticallyAcclaimedBollywood => _criticallyAcclaimedBollywood;
  List<Media> get familyEntertainmentBollywood => _familyEntertainmentBollywood;
  List<Media> get comedyGoldBollywood => _comedyGoldBollywood;
  List<Media> get actionThrillersBollywood => _actionThrillersBollywood;
  List<Media> get romanticDramasBollywood => _romanticDramasBollywood;
  List<Media> get mysteryCrimeBollywood => _mysteryCrimeBollywood;
  List<Media> get biographicalBollywood => _biographicalBollywood;
  List<Media> get webSeriesBollywood => _webSeriesBollywood;
  List<Media> get upcomingBollywood => _upcomingBollywood;
  List<Media> get awardWinnersBollywood => _awardWinnersBollywood;

  // Additional Bollywood getters
  List<Media> get masalaMovies => _masalaMovies;
  List<Media> get patrioticMovies => _patrioticMovies;
  List<Media> get socialDramas => _socialDramas;
  List<Media> get comedyDramas => _comedyDramas;
  List<Media> get actionComedies => _actionComedies;
  List<Media> get romanticComedies => _romanticComedies;
  List<Media> get thrillerComedies => _thrillerComedies;
  List<Media> get familyDramas => _familyDramas;
  List<Media> get youthMovies => _youthMovies;

  // Indian Regional Language getters
  List<Media> get tamilMovies => _tamilMovies;
  List<Media> get teluguMovies => _teluguMovies;
  List<Media> get malayalamMovies => _malayalamMovies;
  List<Media> get marathiMovies => _marathiMovies;
  List<Media> get bengaliMovies => _bengaliMovies;

  // Indian Genre getters
  List<Media> get bollywoodMasala => _bollywoodMasala;
  List<Media> get southIndianAction => _southIndianAction;
  List<Media> get marathiCinema => _marathiCinema;

  // Indian Streaming Platform getters
  List<Media> get hotstarContent => _hotstarContent;
  List<Media> get sonyLIVContent => _sonyLIVContent;
  List<Media> get zee5Content => _zee5Content;
  List<Media> get womenCentric => _womenCentric;
  List<Media> get childrenMovies => _childrenMovies;
  List<Media> get festivalMovies => _festivalMovies;
  List<Media> get regionalCinema => _regionalCinema;
  List<Media> get parallelCinema => _parallelCinema;
  List<Media> get commercialCinema => _commercialCinema;
  List<Media> get artCinema => _artCinema;
  List<Media> get documentaryBollywood => _documentaryBollywood;
  List<Media> get shortFilmsBollywood => _shortFilmsBollywood;
  List<Media> get webSeriesHindi => _webSeriesHindi;
  List<Media> get tvShowsHindi => _tvShowsHindi;
  List<Media> get realityShowsHindi => _realityShowsHindi;
  List<Media> get gameShowsHindi => _gameShowsHindi;
  List<Media> get talkShowsHindi => _talkShowsHindi;
  List<Media> get varietyShowsHindi => _varietyShowsHindi;
  List<Media> get newsShowsHindi => _newsShowsHindi;
  List<Media> get educationalShowsHindi => _educationalShowsHindi;

  // Korean getters
  List<Media> get latestKorean => _latestKorean;
  List<Media> get topRatedKorean => _topRatedKorean;
  List<Media> get actionKorean => _actionKorean;
  List<Media> get thrillerKorean => _thrillerKorean;
  List<Media> get popularKoreanTv => _popularKoreanTv;
  List<Media> get topRatedKoreanTv => _topRatedKoreanTv;
  List<Media> get featuredKorean => _featuredKorean;

  // New Korean getters
  List<Media> get newReleasesKorean => _newReleasesKorean;
  List<Media> get blockbusterHitsKorean => _blockbusterHitsKorean;
  List<Media> get criticallyAcclaimedKorean => _criticallyAcclaimedKorean;
  List<Media> get familyEntertainmentKorean => _familyEntertainmentKorean;
  List<Media> get comedyGoldKorean => _comedyGoldKorean;
  List<Media> get romanticDramasKorean => _romanticDramasKorean;
  List<Media> get mysteryCrimeKorean => _mysteryCrimeKorean;
  List<Media> get biographicalKorean => _biographicalKorean;
  List<Media> get webSeriesKorean => _webSeriesKorean;
  List<Media> get upcomingKorean => _upcomingKorean;
  List<Media> get awardWinnersKorean => _awardWinnersKorean;
  List<Media> get koreanClassics => _koreanClassics;

  // Netflix getters
  List<Media> get topRatedNetflix => _topRatedNetflix;
  List<Media> get actionNetflix => _actionNetflix;
  List<Media> get comedyNetflix => _comedyNetflix;
  List<Media> get dramaNetflix => _dramaNetflix;
  List<Media> get thrillerNetflix => _thrillerNetflix;
  List<Media> get horrorNetflix => _horrorNetflix;
  List<Media> get scifiNetflix => _scifiNetflix;
  List<Media> get newReleasesNetflix => _newReleasesNetflix;
  List<Media> get popularNetflix => _popularNetflix;
  List<Media> get awardWinnersNetflix => _awardWinnersNetflix;
  List<Media> get familyContentNetflix => _familyContentNetflix;
  List<Media> get romanceNetflix => _romanceNetflix;
  List<Media> get mysteryNetflix => _mysteryNetflix;
  List<Media> get crimeNetflix => _crimeNetflix;
  List<Media> get animationNetflix => _animationNetflix;
  List<Media> get documentaryNetflix => _documentaryNetflix;
  List<Media> get internationalNetflix => _internationalNetflix;
  List<Media> get classicNetflix => _classicNetflix;
  List<Media> get upcomingNetflix => _upcomingNetflix;
  List<Media> get criticallyAcclaimedNetflix => _criticallyAcclaimedNetflix;

  // Prime getters
  List<Media> get topRatedPrime => _topRatedPrime;
  List<Media> get actionPrime => _actionPrime;
  List<Media> get comedyPrime => _comedyPrime;
  List<Media> get dramaPrime => _dramaPrime;
  List<Media> get thrillerPrime => _thrillerPrime;
  List<Media> get scifiPrime => _scifiPrime;
  List<Media> get romancePrime => _romancePrime;
  List<Media> get popularTvPrime => _popularTvPrime;
  List<Media> get comedyTvPrime => _comedyTvPrime;
  List<Media> get dramaTvPrime => _dramaTvPrime;
  List<Media> get newReleasesPrime => _newReleasesPrime;
  List<Media> get popularPrime => _popularPrime;
  List<Media> get awardWinnersPrime => _awardWinnersPrime;
  List<Media> get familyContentPrime => _familyContentPrime;
  List<Media> get mysteryPrime => _mysteryPrime;
  List<Media> get crimePrime => _crimePrime;
  List<Media> get animationPrime => _animationPrime;
  List<Media> get documentaryPrime => _documentaryPrime;
  List<Media> get internationalPrime => _internationalPrime;
  List<Media> get classicPrime => _classicPrime;
  List<Media> get upcomingPrime => _upcomingPrime;
  List<Media> get criticallyAcclaimedPrime => _criticallyAcclaimedPrime;
  List<Media> get horrorPrime => _horrorPrime;
  List<Media> get warPrime => _warPrime;
  List<Media> get westernPrime => _westernPrime;
  List<Media> get musicalPrime => _musicalPrime;
  List<Media> get biographicalPrime => _biographicalPrime;
  List<Media> get sportsPrime => _sportsPrime;
  List<Media> get adventurePrime => _adventurePrime;
  List<Media> get fantasyPrime => _fantasyPrime;
  List<Media> get superheroPrime => _superheroPrime;
  List<Media> get indiePrime => _indiePrime;
  List<Media> get foreignPrime => _foreignPrime;
  List<Media> get teenPrime => _teenPrime;
  List<Media> get kidsPrime => _kidsPrime;
  List<Media> get realityTvPrime => _realityTvPrime;
  List<Media> get gameShowPrime => _gameShowPrime;
  List<Media> get talkShowPrime => _talkShowPrime;
  List<Media> get varietyPrime => _varietyPrime;
  List<Media> get newsPrime => _newsPrime;
  List<Media> get educationalPrime => _educationalPrime;

  // Top 250 getters

  // Animated getters
  List<Media> get topRatedAnimated => _topRatedAnimated;
  List<Media> get pixarAnimated => _pixarAnimated;
  List<Media> get ghibliAnimated => _ghibliAnimated;
  List<Media> get recentUpcomingAnimated => _recentUpcomingAnimated;
  List<Media> get popularAnimatedTv => _popularAnimatedTv;
  List<Media> get newReleasesAnimated => _newReleasesAnimated;
  List<Media> get popularAnimated => _popularAnimated;
  List<Media> get awardWinnersAnimated => _awardWinnersAnimated;
  List<Media> get familyAnimated => _familyAnimated;
  List<Media> get comedyAnimated => _comedyAnimated;
  List<Media> get adventureAnimated => _adventureAnimated;
  List<Media> get fantasyAnimated => _fantasyAnimated;
  List<Media> get superheroAnimated => _superheroAnimated;
  List<Media> get musicalAnimated => _musicalAnimated;
  List<Media> get classicAnimated => _classicAnimated;
  List<Media> get upcomingAnimated => _upcomingAnimated;
  List<Media> get criticallyAcclaimedAnimated => _criticallyAcclaimedAnimated;
  List<Media> get indieAnimated => _indieAnimated;
  List<Media> get foreignAnimated => _foreignAnimated;
  List<Media> get teenAnimated => _teenAnimated;
  List<Media> get kidsAnimated => _kidsAnimated;
  List<Media> get stopMotionAnimated => _stopMotionAnimated;
  List<Media> get computerGeneratedAnimated => _computerGeneratedAnimated;
  List<Media> get handDrawnAnimated => _handDrawnAnimated;
  List<Media> get animeAnimated => _animeAnimated;
  List<Media> get europeanAnimated => _europeanAnimated;
  List<Media> get disneyAnimated => _disneyAnimated;
  List<Media> get dreamworksAnimated => _dreamworksAnimated;
  List<Media> get illuminationAnimated => _illuminationAnimated;
  List<Media> get sonyAnimated => _sonyAnimated;
  List<Media> get warnerAnimated => _warnerAnimated;
  List<Media> get paramountAnimated => _paramountAnimated;
  List<Media> get universalAnimated => _universalAnimated;
  List<Media> get foxAnimated => _foxAnimated;
  List<Media> get mangaAnimated => _mangaAnimated;
  List<Media> get cartoonNetworkAnimated => _cartoonNetworkAnimated;
  List<Media> get nickelodeonAnimated => _nickelodeonAnimated;
  List<Media> get disneyChannelAnimated => _disneyChannelAnimated;
  List<Media> get netflixAnimated => _netflixAnimated;
  List<Media> get primeAnimated => _primeAnimated;
  List<Media> get huluAnimated => _huluAnimated;
  List<Media> get hboAnimated => _hboAnimated;
  List<Media> get appleAnimated => _appleAnimated;
  List<Media> get peacockAnimated => _peacockAnimated;
  List<Media> get paramountPlusAnimated => _paramountPlusAnimated;
  List<Media> get disneyPlusAnimated => _disneyPlusAnimated;
  List<Media> get maxAnimated => _maxAnimated;

  // Mindfucks getters

  // Indian Cartoons getters

  // Documentaries getters
  List<Media> get topRatedDocumentaries => _topRatedDocumentaries;
  List<Media> get recentDocumentaries => _recentDocumentaries;
  List<Media> get bioDocumentaries => _bioDocumentaries;
  List<Media> get netflixDocumentaries => _netflixDocumentaries;
  List<Media> get primeDocumentaries => _primeDocumentaries;
  List<Media> get popularDocuseries => _popularDocuseries;

  // Adventure getters

  // Loading getters
  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingNewlyReleased => _isLoadingNewlyReleased;
  bool get isLoadingMostPopular => _isLoadingMostPopular;
  bool get isLoadingTopRatedMovies => _isLoadingTopRatedMovies;
  bool get isLoadingTopRatedTvShows => _isLoadingTopRatedTvShows;
  bool get isLoadingActionAdventure => _isLoadingActionAdventure;
  bool get isLoadingComedy => _isLoadingComedy;
  bool get isLoadingScifiFantasy => _isLoadingScifiFantasy;
  bool get isLoadingHorror => _isLoadingHorror;
  bool get isLoadingThriller => _isLoadingThriller;
  bool get isLoadingDrama => _isLoadingDrama;
  bool get isLoadingRomance => _isLoadingRomance;
  bool get isLoadingAnimation => _isLoadingAnimation;
  bool get isLoadingFamily => _isLoadingFamily;
  bool get isLoadingDocumentary => _isLoadingDocumentary;
  bool get isLoadingCrime => _isLoadingCrime;
  bool get isLoadingMystery => _isLoadingMystery;
  bool get isLoadingWar => _isLoadingWar;
  bool get isLoadingWestern => _isLoadingWestern;
  bool get isLoadingMusic => _isLoadingMusic;
  bool get isLoadingHistory => _isLoadingHistory;

  // Special curated loading getters
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingAwardWinners => _isLoadingAwardWinners;
  bool get isLoadingIndie => _isLoadingIndie;
  bool get isLoadingForeign => _isLoadingForeign;
  bool get isLoadingClassics => _isLoadingClassics;
  bool get isLoadingTeen => _isLoadingTeen;
  bool get isSearching => _isSearching;

  // Bollywood loading getters
  bool get isLoadingLatestBollywood => _isLoadingLatestBollywood;
  bool get isLoadingClassicsBollywood => _isLoadingClassicsBollywood;
  bool get isLoadingNetflixBollywood => _isLoadingNetflixBollywood;
  bool get isLoadingPrimeBollywood => _isLoadingPrimeBollywood;
  bool get isLoadingActionBollywood => _isLoadingActionBollywood;
  bool get isLoadingRomanceBollywood => _isLoadingRomanceBollywood;
  bool get isLoadingThrillerBollywood => _isLoadingThrillerBollywood;
  bool get isLoadingPopularHindiTv => _isLoadingPopularHindiTv;
  bool get isLoadingTopRatedHindiTv => _isLoadingTopRatedHindiTv;

  // New Bollywood loading getters
  bool get isLoadingNewReleasesBollywood => _isLoadingNewReleasesBollywood;
  bool get isLoadingBlockbusterHitsBollywood =>
      _isLoadingBlockbusterHitsBollywood;
  bool get isLoadingCriticallyAcclaimedBollywood =>
      _isLoadingCriticallyAcclaimedBollywood;
  bool get isLoadingFamilyEntertainmentBollywood =>
      _isLoadingFamilyEntertainmentBollywood;
  bool get isLoadingComedyGoldBollywood => _isLoadingComedyGoldBollywood;
  bool get isLoadingActionThrillersBollywood =>
      _isLoadingActionThrillersBollywood;
  bool get isLoadingRomanticDramasBollywood =>
      _isLoadingRomanticDramasBollywood;
  bool get isLoadingMysteryCrimeBollywood => _isLoadingMysteryCrimeBollywood;
  bool get isLoadingBiographicalBollywood => _isLoadingBiographicalBollywood;
  bool get isLoadingWebSeriesBollywood => _isLoadingWebSeriesBollywood;
  bool get isLoadingUpcomingBollywood => _isLoadingUpcomingBollywood;
  bool get isLoadingAwardWinnersBollywood => _isLoadingAwardWinnersBollywood;

  // Korean loading getters
  bool get isLoadingLatestKorean => _isLoadingLatestKorean;
  bool get isLoadingTopRatedKorean => _isLoadingTopRatedKorean;
  bool get isLoadingActionKorean => _isLoadingActionKorean;
  bool get isLoadingThrillerKorean => _isLoadingThrillerKorean;
  bool get isLoadingPopularKoreanTv => _isLoadingPopularKoreanTv;
  bool get isLoadingTopRatedKoreanTv => _isLoadingTopRatedKoreanTv;
  bool get isLoadingFeaturedKorean => _isLoadingFeaturedKorean;

  // Indian Regional Language loading getters
  bool get isLoadingTamilMovies => _isLoadingTamilMovies;
  bool get isLoadingTeluguMovies => _isLoadingTeluguMovies;
  bool get isLoadingMalayalamMovies => _isLoadingMalayalamMovies;
  bool get isLoadingMarathiMovies => _isLoadingMarathiMovies;
  bool get isLoadingBengaliMovies => _isLoadingBengaliMovies;

  // Indian Genre loading getters
  bool get isLoadingBollywoodMasala => _isLoadingBollywoodMasala;
  bool get isLoadingSouthIndianAction => _isLoadingSouthIndianAction;
  bool get isLoadingMarathiCinema => _isLoadingMarathiCinema;

  // Indian Streaming Platform loading getters
  bool get isLoadingHotstarContent => _isLoadingHotstarContent;
  bool get isLoadingSonyLIVContent => _isLoadingSonyLIVContent;
  bool get isLoadingZee5Content => _isLoadingZee5Content;

  // New Korean loading getters
  bool get isLoadingNewReleasesKorean => _isLoadingNewReleasesKorean;
  bool get isLoadingBlockbusterHitsKorean => _isLoadingBlockbusterHitsKorean;
  bool get isLoadingCriticallyAcclaimedKorean =>
      _isLoadingCriticallyAcclaimedKorean;
  bool get isLoadingFamilyEntertainmentKorean =>
      _isLoadingFamilyEntertainmentKorean;
  bool get isLoadingComedyGoldKorean => _isLoadingComedyGoldKorean;
  bool get isLoadingRomanticDramasKorean => _isLoadingRomanticDramasKorean;
  bool get isLoadingMysteryCrimeKorean => _isLoadingMysteryCrimeKorean;
  bool get isLoadingBiographicalKorean => _isLoadingBiographicalKorean;
  bool get isLoadingWebSeriesKorean => _isLoadingWebSeriesKorean;
  bool get isLoadingUpcomingKorean => _isLoadingUpcomingKorean;
  bool get isLoadingAwardWinnersKorean => _isLoadingAwardWinnersKorean;
  bool get isLoadingKoreanClassics => _isLoadingKoreanClassics;

  // Netflix loading getters
  bool get isLoadingTopRatedNetflix => _isLoadingTopRatedNetflix;
  bool get isLoadingActionNetflix => _isLoadingActionNetflix;
  bool get isLoadingComedyNetflix => _isLoadingComedyNetflix;
  bool get isLoadingDramaNetflix => _isLoadingDramaNetflix;
  bool get isLoadingThrillerNetflix => _isLoadingThrillerNetflix;
  bool get isLoadingHorrorNetflix => _isLoadingHorrorNetflix;
  bool get isLoadingScifiNetflix => _isLoadingScifiNetflix;
  bool get isLoadingNewReleasesNetflix => _isLoadingNewReleasesNetflix;
  bool get isLoadingPopularNetflix => _isLoadingPopularNetflix;
  bool get isLoadingAwardWinnersNetflix => _isLoadingAwardWinnersNetflix;
  bool get isLoadingFamilyContentNetflix => _isLoadingFamilyContentNetflix;
  bool get isLoadingRomanceNetflix => _isLoadingRomanceNetflix;
  bool get isLoadingMysteryNetflix => _isLoadingMysteryNetflix;
  bool get isLoadingCrimeNetflix => _isLoadingCrimeNetflix;
  bool get isLoadingAnimationNetflix => _isLoadingAnimationNetflix;
  bool get isLoadingDocumentaryNetflix => _isLoadingDocumentaryNetflix;
  bool get isLoadingInternationalNetflix => _isLoadingInternationalNetflix;
  bool get isLoadingClassicNetflix => _isLoadingClassicNetflix;
  bool get isLoadingUpcomingNetflix => _isLoadingUpcomingNetflix;
  bool get isLoadingCriticallyAcclaimedNetflix =>
      _isLoadingCriticallyAcclaimedNetflix;

  // Prime loading getters
  bool get isLoadingTopRatedPrime => _isLoadingTopRatedPrime;
  bool get isLoadingActionPrime => _isLoadingActionPrime;
  bool get isLoadingComedyPrime => _isLoadingComedyPrime;
  bool get isLoadingDramaPrime => _isLoadingDramaPrime;
  bool get isLoadingThrillerPrime => _isLoadingThrillerPrime;
  bool get isLoadingScifiPrime => _isLoadingScifiPrime;
  bool get isLoadingRomancePrime => _isLoadingRomancePrime;
  bool get isLoadingPopularTvPrime => _isLoadingPopularTvPrime;
  bool get isLoadingComedyTvPrime => _isLoadingComedyTvPrime;
  bool get isLoadingDramaTvPrime => _isLoadingDramaTvPrime;
  bool get isLoadingNewReleasesPrime => _isLoadingNewReleasesPrime;
  bool get isLoadingPopularPrime => _isLoadingPopularPrime;
  bool get isLoadingAwardWinnersPrime => _isLoadingAwardWinnersPrime;
  bool get isLoadingFamilyContentPrime => _isLoadingFamilyContentPrime;
  bool get isLoadingMysteryPrime => _isLoadingMysteryPrime;
  bool get isLoadingCrimePrime => _isLoadingCrimePrime;
  bool get isLoadingAnimationPrime => _isLoadingAnimationPrime;
  bool get isLoadingDocumentaryPrime => _isLoadingDocumentaryPrime;
  bool get isLoadingInternationalPrime => _isLoadingInternationalPrime;
  bool get isLoadingClassicPrime => _isLoadingClassicPrime;
  bool get isLoadingUpcomingPrime => _isLoadingUpcomingPrime;
  bool get isLoadingCriticallyAcclaimedPrime =>
      _isLoadingCriticallyAcclaimedPrime;
  bool get isLoadingHorrorPrime => _isLoadingHorrorPrime;
  bool get isLoadingWarPrime => _isLoadingWarPrime;
  bool get isLoadingWesternPrime => _isLoadingWesternPrime;
  bool get isLoadingMusicalPrime => _isLoadingMusicalPrime;
  bool get isLoadingBiographicalPrime => _isLoadingBiographicalPrime;
  bool get isLoadingSportsPrime => _isLoadingSportsPrime;
  bool get isLoadingAdventurePrime => _isLoadingAdventurePrime;
  bool get isLoadingFantasyPrime => _isLoadingFantasyPrime;
  bool get isLoadingSuperheroPrime => _isLoadingSuperheroPrime;
  bool get isLoadingIndiePrime => _isLoadingIndiePrime;
  bool get isLoadingForeignPrime => _isLoadingForeignPrime;
  bool get isLoadingTeenPrime => _isLoadingTeenPrime;
  bool get isLoadingKidsPrime => _isLoadingKidsPrime;
  bool get isLoadingRealityTvPrime => _isLoadingRealityTvPrime;
  bool get isLoadingGameShowPrime => _isLoadingGameShowPrime;
  bool get isLoadingTalkShowPrime => _isLoadingTalkShowPrime;
  bool get isLoadingVarietyPrime => _isLoadingVarietyPrime;
  bool get isLoadingNewsPrime => _isLoadingNewsPrime;
  bool get isLoadingEducationalPrime => _isLoadingEducationalPrime;

  // Top 250 loading getters

  // Animated loading getters
  bool get isLoadingTopRatedAnimated => _isLoadingTopRatedAnimated;
  bool get isLoadingPixarAnimated => _isLoadingPixarAnimated;
  bool get isLoadingGhibliAnimated => _isLoadingGhibliAnimated;
  bool get isLoadingRecentUpcomingAnimated => _isLoadingRecentUpcomingAnimated;
  bool get isLoadingPopularAnimatedTv => _isLoadingPopularAnimatedTv;
  bool get isLoadingNewReleasesAnimated => _isLoadingNewReleasesAnimated;
  bool get isLoadingPopularAnimated => _isLoadingPopularAnimated;
  bool get isLoadingAwardWinnersAnimated => _isLoadingAwardWinnersAnimated;
  bool get isLoadingFamilyAnimated => _isLoadingFamilyAnimated;
  bool get isLoadingComedyAnimated => _isLoadingComedyAnimated;
  bool get isLoadingAdventureAnimated => _isLoadingAdventureAnimated;
  bool get isLoadingFantasyAnimated => _isLoadingFantasyAnimated;
  bool get isLoadingSuperheroAnimated => _isLoadingSuperheroAnimated;
  bool get isLoadingMusicalAnimated => _isLoadingMusicalAnimated;
  bool get isLoadingClassicAnimated => _isLoadingClassicAnimated;
  bool get isLoadingUpcomingAnimated => _isLoadingUpcomingAnimated;
  bool get isLoadingCriticallyAcclaimedAnimated =>
      _isLoadingCriticallyAcclaimedAnimated;
  bool get isLoadingIndieAnimated => _isLoadingIndieAnimated;
  bool get isLoadingForeignAnimated => _isLoadingForeignAnimated;
  bool get isLoadingTeenAnimated => _isLoadingTeenAnimated;
  bool get isLoadingKidsAnimated => _isLoadingKidsAnimated;
  bool get isLoadingStopMotionAnimated => _isLoadingStopMotionAnimated;
  bool get isLoadingComputerGeneratedAnimated =>
      _isLoadingComputerGeneratedAnimated;
  bool get isLoadingHandDrawnAnimated => _isLoadingHandDrawnAnimated;
  bool get isLoadingAnimeAnimated => _isLoadingAnimeAnimated;
  bool get isLoadingEuropeanAnimated => _isLoadingEuropeanAnimated;
  bool get isLoadingDisneyAnimated => _isLoadingDisneyAnimated;
  bool get isLoadingDreamworksAnimated => _isLoadingDreamworksAnimated;
  bool get isLoadingIlluminationAnimated => _isLoadingIlluminationAnimated;
  bool get isLoadingSonyAnimated => _isLoadingSonyAnimated;
  bool get isLoadingWarnerAnimated => _isLoadingWarnerAnimated;
  bool get isLoadingParamountAnimated => _isLoadingParamountAnimated;
  bool get isLoadingUniversalAnimated => _isLoadingUniversalAnimated;
  bool get isLoadingFoxAnimated => _isLoadingFoxAnimated;
  bool get isLoadingMangaAnimated => _isLoadingMangaAnimated;
  bool get isLoadingCartoonNetworkAnimated => _isLoadingCartoonNetworkAnimated;
  bool get isLoadingNickelodeonAnimated => _isLoadingNickelodeonAnimated;
  bool get isLoadingDisneyChannelAnimated => _isLoadingDisneyChannelAnimated;
  bool get isLoadingNetflixAnimated => _isLoadingNetflixAnimated;
  bool get isLoadingPrimeAnimated => _isLoadingPrimeAnimated;
  bool get isLoadingHuluAnimated => _isLoadingHuluAnimated;
  bool get isLoadingHboAnimated => _isLoadingHboAnimated;
  bool get isLoadingAppleAnimated => _isLoadingAppleAnimated;
  bool get isLoadingPeacockAnimated => _isLoadingPeacockAnimated;
  bool get isLoadingParamountPlusAnimated => _isLoadingParamountPlusAnimated;
  bool get isLoadingDisneyPlusAnimated => _isLoadingDisneyPlusAnimated;
  bool get isLoadingMaxAnimated => _isLoadingMaxAnimated;

  // Mindfucks loading getters

  // Indian Cartoons loading getters

  // Documentaries loading getters
  bool get isLoadingTopRatedDocumentaries => _isLoadingTopRatedDocumentaries;
  bool get isLoadingRecentDocumentaries => _isLoadingRecentDocumentaries;
  bool get isLoadingBioDocumentaries => _isLoadingBioDocumentaries;
  bool get isLoadingNetflixDocumentaries => _isLoadingNetflixDocumentaries;
  bool get isLoadingPrimeDocumentaries => _isLoadingPrimeDocumentaries;
  bool get isLoadingPopularDocuseries => _isLoadingPopularDocuseries;

  // Adventure loading getters

  // Error getters
  String? get popularError => _popularError;
  String? get newlyReleasedError => _newlyReleasedError;
  String? get mostPopularError => _mostPopularError;
  String? get topRatedMoviesError => _topRatedMoviesError;
  String? get topRatedTvShowsError => _topRatedTvShowsError;
  String? get actionAdventureError => _actionAdventureError;
  String? get comedyError => _comedyError;
  String? get scifiFantasyError => _scifiFantasyError;
  String? get horrorError => _horrorError;
  String? get thrillerError => _thrillerError;
  String? get dramaError => _dramaError;
  String? get romanceError => _romanceError;
  String? get animationError => _animationError;
  String? get familyError => _familyError;
  String? get documentaryError => _documentaryError;
  String? get crimeError => _crimeError;
  String? get mysteryError => _mysteryError;
  String? get warError => _warError;
  String? get westernError => _westernError;
  String? get musicError => _musicError;
  String? get historyError => _historyError;

  // Special curated error getters
  String? get upcomingError => _upcomingError;
  String? get awardWinnersError => _awardWinnersError;
  String? get indieError => _indieError;
  String? get foreignError => _foreignError;
  String? get classicsError => _classicsError;
  String? get teenError => _teenError;
  String? get searchError => _searchError;

  // Bollywood error getters
  String? get latestBollywoodError => _latestBollywoodError;
  String? get classicsBollywoodError => _classicsBollywoodError;
  String? get netflixBollywoodError => _netflixBollywoodError;
  String? get primeBollywoodError => _primeBollywoodError;
  String? get actionBollywoodError => _actionBollywoodError;
  String? get romanceBollywoodError => _romanceBollywoodError;
  String? get thrillerBollywoodError => _thrillerBollywoodError;
  String? get popularHindiTvError => _popularHindiTvError;
  String? get topRatedHindiTvError => _topRatedHindiTvError;

  // New Bollywood error getters
  String? get newReleasesBollywoodError => _newReleasesBollywoodError;
  String? get blockbusterHitsBollywoodError => _blockbusterHitsBollywoodError;
  String? get criticallyAcclaimedBollywoodError =>
      _criticallyAcclaimedBollywoodError;
  String? get familyEntertainmentBollywoodError =>
      _familyEntertainmentBollywoodError;
  String? get comedyGoldBollywoodError => _comedyGoldBollywoodError;
  String? get actionThrillersBollywoodError => _actionThrillersBollywoodError;
  String? get romanticDramasBollywoodError => _romanticDramasBollywoodError;
  String? get mysteryCrimeBollywoodError => _mysteryCrimeBollywoodError;
  String? get biographicalBollywoodError => _biographicalBollywoodError;
  String? get webSeriesBollywoodError => _webSeriesBollywoodError;
  String? get upcomingBollywoodError => _upcomingBollywoodError;
  String? get awardWinnersBollywoodError => _awardWinnersBollywoodError;

  // Korean error getters
  String? get latestKoreanError => _latestKoreanError;
  String? get topRatedKoreanError => _topRatedKoreanError;
  String? get actionKoreanError => _actionKoreanError;
  String? get thrillerKoreanError => _thrillerKoreanError;
  String? get popularKoreanTvError => _popularKoreanTvError;
  String? get topRatedKoreanTvError => _topRatedKoreanTvError;
  String? get featuredKoreanError => _featuredKoreanError;

  // Indian Regional Language error getters
  String? get tamilMoviesError => _tamilMoviesError;
  String? get teluguMoviesError => _teluguMoviesError;
  String? get malayalamMoviesError => _malayalamMoviesError;
  String? get marathiMoviesError => _marathiMoviesError;
  String? get bengaliMoviesError => _bengaliMoviesError;

  // Indian Genre error getters
  String? get bollywoodMasalaError => _bollywoodMasalaError;
  String? get southIndianActionError => _southIndianActionError;
  String? get marathiCinemaError => _marathiCinemaError;

  // Indian Streaming Platform error getters
  String? get hotstarContentError => _hotstarContentError;
  String? get sonyLIVContentError => _sonyLIVContentError;
  String? get zee5ContentError => _zee5ContentError;

  // New Korean error getters
  String? get newReleasesKoreanError => _newReleasesKoreanError;
  String? get awardWinnersKoreanError => _awardWinnersKoreanError;
  String? get blockbusterHitsKoreanError => _blockbusterHitsKoreanError;
  String? get criticallyAcclaimedKoreanError => _criticallyAcclaimedKoreanError;
  String? get familyEntertainmentKoreanError => _familyEntertainmentKoreanError;
  String? get comedyGoldKoreanError => _comedyGoldKoreanError;
  String? get romanticDramasKoreanError => _romanticDramasKoreanError;
  String? get mysteryCrimeKoreanError => _mysteryCrimeKoreanError;
  String? get biographicalKoreanError => _biographicalKoreanError;
  String? get webSeriesKoreanError => _webSeriesKoreanError;
  String? get upcomingKoreanError => _upcomingKoreanError;
  String? get koreanClassicsError => _koreanClassicsError;

  // Netflix error getters
  String? get topRatedNetflixError => _topRatedNetflixError;
  String? get actionNetflixError => _actionNetflixError;
  String? get comedyNetflixError => _comedyNetflixError;
  String? get dramaNetflixError => _dramaNetflixError;
  String? get thrillerNetflixError => _thrillerNetflixError;
  String? get horrorNetflixError => _horrorNetflixError;
  String? get scifiNetflixError => _scifiNetflixError;
  String? get newReleasesNetflixError => _newReleasesNetflixError;
  String? get popularNetflixError => _popularNetflixError;
  String? get awardWinnersNetflixError => _awardWinnersNetflixError;
  String? get familyContentNetflixError => _familyContentNetflixError;
  String? get romanceNetflixError => _romanceNetflixError;
  String? get mysteryNetflixError => _mysteryNetflixError;
  String? get crimeNetflixError => _crimeNetflixError;
  String? get animationNetflixError => _animationNetflixError;
  String? get documentaryNetflixError => _documentaryNetflixError;
  String? get internationalNetflixError => _internationalNetflixError;
  String? get classicNetflixError => _classicNetflixError;
  String? get upcomingNetflixError => _upcomingNetflixError;
  String? get criticallyAcclaimedNetflixError =>
      _criticallyAcclaimedNetflixError;

  // Prime error getters
  String? get topRatedPrimeError => _topRatedPrimeError;
  String? get actionPrimeError => _actionPrimeError;
  String? get comedyPrimeError => _comedyPrimeError;
  String? get dramaPrimeError => _dramaPrimeError;
  String? get thrillerPrimeError => _thrillerPrimeError;
  String? get scifiPrimeError => _scifiPrimeError;
  String? get romancePrimeError => _romancePrimeError;
  String? get popularTvPrimeError => _popularTvPrimeError;
  String? get comedyTvPrimeError => _comedyTvPrimeError;
  String? get dramaTvPrimeError => _dramaTvPrimeError;
  String? get newReleasesPrimeError => _newReleasesPrimeError;
  String? get popularPrimeError => _popularPrimeError;
  String? get awardWinnersPrimeError => _awardWinnersPrimeError;
  String? get familyContentPrimeError => _familyContentPrimeError;
  String? get mysteryPrimeError => _mysteryPrimeError;
  String? get crimePrimeError => _crimePrimeError;
  String? get animationPrimeError => _animationPrimeError;
  String? get documentaryPrimeError => _documentaryPrimeError;
  String? get internationalPrimeError => _internationalPrimeError;
  String? get classicPrimeError => _classicPrimeError;
  String? get upcomingPrimeError => _upcomingPrimeError;
  String? get criticallyAcclaimedPrimeError => _criticallyAcclaimedPrimeError;
  String? get horrorPrimeError => _horrorPrimeError;
  String? get warPrimeError => _warPrimeError;
  String? get westernPrimeError => _westernPrimeError;
  String? get musicalPrimeError => _musicalPrimeError;
  String? get biographicalPrimeError => _biographicalPrimeError;
  String? get sportsPrimeError => _sportsPrimeError;
  String? get adventurePrimeError => _adventurePrimeError;
  String? get fantasyPrimeError => _fantasyPrimeError;
  String? get superheroPrimeError => _superheroPrimeError;
  String? get indiePrimeError => _indiePrimeError;
  String? get foreignPrimeError => _foreignPrimeError;
  String? get teenPrimeError => _teenPrimeError;
  String? get kidsPrimeError => _kidsPrimeError;
  String? get realityTvPrimeError => _realityTvPrimeError;
  String? get gameShowPrimeError => _gameShowPrimeError;
  String? get talkShowPrimeError => _talkShowPrimeError;
  String? get varietyPrimeError => _varietyPrimeError;
  String? get newsPrimeError => _newsPrimeError;
  String? get educationalPrimeError => _educationalPrimeError;

  // Top 250 error getters

  // Animated error getters
  String? get topRatedAnimatedError => _topRatedAnimatedError;
  String? get pixarAnimatedError => _pixarAnimatedError;
  String? get ghibliAnimatedError => _ghibliAnimatedError;
  String? get recentUpcomingAnimatedError => _recentUpcomingAnimatedError;
  String? get popularAnimatedTvError => _popularAnimatedTvError;
  String? get newReleasesAnimatedError => _newReleasesAnimatedError;
  String? get popularAnimatedError => _popularAnimatedError;
  String? get awardWinnersAnimatedError => _awardWinnersAnimatedError;
  String? get familyAnimatedError => _familyAnimatedError;
  String? get comedyAnimatedError => _comedyAnimatedError;
  String? get adventureAnimatedError => _adventureAnimatedError;
  String? get fantasyAnimatedError => _fantasyAnimatedError;
  String? get superheroAnimatedError => _superheroAnimatedError;
  String? get musicalAnimatedError => _musicalAnimatedError;
  String? get classicAnimatedError => _classicAnimatedError;
  String? get upcomingAnimatedError => _upcomingAnimatedError;
  String? get criticallyAcclaimedAnimatedError =>
      _criticallyAcclaimedAnimatedError;
  String? get indieAnimatedError => _indieAnimatedError;
  String? get foreignAnimatedError => _foreignAnimatedError;
  String? get teenAnimatedError => _teenAnimatedError;
  String? get kidsAnimatedError => _kidsAnimatedError;
  String? get stopMotionAnimatedError => _stopMotionAnimatedError;
  String? get computerGeneratedAnimatedError => _computerGeneratedAnimatedError;
  String? get handDrawnAnimatedError => _handDrawnAnimatedError;
  String? get animeAnimatedError => _animeAnimatedError;
  String? get europeanAnimatedError => _europeanAnimatedError;
  String? get disneyAnimatedError => _disneyAnimatedError;
  String? get dreamworksAnimatedError => _dreamworksAnimatedError;
  String? get illuminationAnimatedError => _illuminationAnimatedError;
  String? get sonyAnimatedError => _sonyAnimatedError;
  String? get warnerAnimatedError => _warnerAnimatedError;
  String? get paramountAnimatedError => _paramountAnimatedError;
  String? get universalAnimatedError => _universalAnimatedError;
  String? get foxAnimatedError => _foxAnimatedError;
  String? get mangaAnimatedError => _mangaAnimatedError;
  String? get cartoonNetworkAnimatedError => _cartoonNetworkAnimatedError;
  String? get nickelodeonAnimatedError => _nickelodeonAnimatedError;
  String? get disneyChannelAnimatedError => _disneyChannelAnimatedError;
  String? get netflixAnimatedError => _netflixAnimatedError;
  String? get primeAnimatedError => _primeAnimatedError;
  String? get huluAnimatedError => _huluAnimatedError;
  String? get hboAnimatedError => _hboAnimatedError;
  String? get appleAnimatedError => _appleAnimatedError;
  String? get peacockAnimatedError => _peacockAnimatedError;
  String? get paramountPlusAnimatedError => _paramountPlusAnimatedError;
  String? get disneyPlusAnimatedError => _disneyPlusAnimatedError;
  String? get maxAnimatedError => _maxAnimatedError;

  // Mindfucks error getters

  // Indian Cartoons error getters

  // Documentaries error getters
  String? get topRatedDocumentariesError => _topRatedDocumentariesError;
  String? get recentDocumentariesError => _recentDocumentariesError;
  String? get bioDocumentariesError => _bioDocumentariesError;
  String? get netflixDocumentariesError => _netflixDocumentariesError;
  String? get primeDocumentariesError => _primeDocumentariesError;
  String? get popularDocuseriesError => _popularDocuseriesError;

  // Tracks whether the home catalogue has been loaded at least once
  bool _hasLoadedHome = false;
  bool get hasLoadedHome => _hasLoadedHome;

  // Adventure error getters
  String? get adventureError => _adventureError;

  // Load all catalogue data
  Future<void> loadCatalogue() async {
    await Future.wait([
      loadPopularNow(),
      loadNewlyReleased(),
      loadMostPopular(),
      loadTopRatedMovies(),
      loadTopRatedTvShows(),
      loadActionAdventure(),
      loadComedy(),
      loadScifiFantasy(),
      loadHorror(),
      loadThriller(),
      loadDrama(),
      loadRomance(),
      loadAnimation(),
      loadFamily(),
      loadDocumentary(),
      loadCrime(),
      loadMystery(),
      loadWar(),
      loadWestern(),
      loadMusic(),
      loadHistory(),
      loadUpcoming(),
      loadAwardWinners(),
      loadIndie(),
      loadForeign(),
      loadClassics(),
      loadTeen(),
      loadSuperheroMovies(),
      loadMusicalMovies(),
      loadSportsMovies(),
      loadBiographicalMovies(),
      loadSpyThrillers(),
    ]);
    // Mark initial load completed so we don't show the global loading overlay again
    _hasLoadedHome = true;
    notifyListeners();
  }

  // Load Bollywood catalogue data
  Future<void> loadBollywoodCatalogue() async {
    await Future.wait([
      loadLatestBollywood(),
      loadClassicsBollywood(),
      loadNetflixBollywood(),
      loadPrimeBollywood(),
      loadActionBollywood(),
      loadRomanceBollywood(),
      loadThrillerBollywood(),
      loadPopularHindiTv(),
      loadTopRatedHindiTv(),
      loadNewReleasesBollywood(),
      loadBlockbusterHitsBollywood(),
      loadCriticallyAcclaimedBollywood(),
      loadFamilyEntertainmentBollywood(),
      loadComedyGoldBollywood(),
      loadActionThrillersBollywood(),
      loadRomanticDramasBollywood(),
      loadMysteryCrimeBollywood(),
      loadBiographicalBollywood(),
      loadWebSeriesBollywood(),
      loadUpcomingBollywood(),
      loadAwardWinnersBollywood(),
      loadMasalaMovies(),
      loadPatrioticMovies(),
      loadSocialDramas(),
      loadComedyDramas(),
      loadActionComedies(),
      loadTvShowsHindi(),
      loadRealityShowsHindi(),
    ]);
  }

  // Load Hollywood catalogue data (now using Indian content)
  Future<void> loadHollywoodCatalogue() async {
    await Future.wait([
      loadActionAdventure(),
      loadComedy(),
      loadScifiFantasy(),
      loadHorror(),
      loadThriller(),
      loadDrama(),
      loadRomance(),
      loadAnimation(),
      loadFamily(),
      loadDocumentary(),
      loadCrime(),
      loadMystery(),
      loadWar(),
      loadWestern(),
      loadMusic(),
      loadHistory(),
      loadUpcoming(),
      loadAwardWinners(),
      loadIndie(),
      loadForeign(),
      loadClassics(),
      loadTeen(),
      loadSuperheroMovies(),
      loadMusicalMovies(),
      loadSportsMovies(),
      loadBiographicalMovies(),
      loadSpyThrillers(),
    ]);
    // Mark initial load completed as well (home depends on both groups)
    _hasLoadedHome = true;
    notifyListeners();
  }

  // Refresh Hollywood catalogue data
  Future<void> refreshHollywoodCatalogue() async {
    await loadHollywoodCatalogue();
  }

  // Load Korean catalogue data
  Future<void> loadKoreanCatalogue() async {
    await Future.wait([
      loadFeaturedKorean(),
      loadLatestKorean(),
      loadTopRatedKorean(),
      loadActionKorean(),
      loadThrillerKorean(),
      loadPopularKoreanTv(),
      loadTopRatedKoreanTv(),
      loadNewReleasesKorean(),
      loadBlockbusterHitsKorean(),
      loadCriticallyAcclaimedKorean(),
      loadFamilyEntertainmentKorean(),
      loadComedyGoldKorean(),
      loadRomanticDramasKorean(),
      loadMysteryCrimeKorean(),
      loadBiographicalKorean(),
      loadWebSeriesKorean(),
      loadUpcomingKorean(),
      loadAwardWinnersKorean(),
      loadKoreanClassics(),
    ]);
  }

  // Load Netflix catalogue data (Indian content)
  Future<void> loadNetflixCatalogue() async {
    await Future.wait([
      loadTopRatedNetflix(),
      loadActionNetflix(),
      loadComedyNetflix(),
      loadDramaNetflix(),
      loadThrillerNetflix(),
      loadHorrorNetflix(),
      loadScifiNetflix(),
      loadNewReleasesNetflix(),
      loadPopularNetflix(),
      loadAwardWinnersNetflix(),
      loadFamilyContentNetflix(),
      loadRomanceNetflix(),
      loadMysteryNetflix(),
      loadCrimeNetflix(),
      loadAnimationNetflix(),
      loadDocumentaryNetflix(),
      loadInternationalNetflix(),
      loadClassicNetflix(),
      loadUpcomingNetflix(),
      loadCriticallyAcclaimedNetflix(),
    ]);
  }

  // Load Prime catalogue data (Indian content)
  Future<void> loadPrimeCatalogue() async {
    await Future.wait([
      loadTopRatedPrime(),
      loadActionPrime(),
      loadComedyPrime(),
      loadDramaPrime(),
      loadThrillerPrime(),
      loadScifiPrime(),
      loadRomancePrime(),
      loadPopularTvPrime(),
      loadComedyTvPrime(),
      loadDramaTvPrime(),
      loadNewReleasesPrime(),
      loadPopularPrime(),
      loadAwardWinnersPrime(),
      loadFamilyContentPrime(),
      loadMysteryPrime(),
      loadCrimePrime(),
      loadAnimationPrime(),
      loadDocumentaryPrime(),
      loadInternationalPrime(),
      loadClassicPrime(),
      loadUpcomingPrime(),
      loadCriticallyAcclaimedPrime(),
      loadHorrorPrime(),
      loadWarPrime(),
      loadWesternPrime(),
      loadMusicalPrime(),
      loadBiographicalPrime(),
      loadSportsPrime(),
      loadAdventurePrime(),
      loadFantasyPrime(),
      loadSuperheroPrime(),
      loadIndiePrime(),
      loadForeignPrime(),
      loadTeenPrime(),
      loadKidsPrime(),
      loadRealityTvPrime(),
      loadGameShowPrime(),
      loadTalkShowPrime(),
      loadVarietyPrime(),
      loadNewsPrime(),
      loadEducationalPrime(),
    ]);
  }

  // Load Indian Regional Language Catalogue
  Future<void> loadIndianRegionalCatalogue() async {
    await Future.wait([
      loadTamilMovies(),
      loadTeluguMovies(),
      loadMalayalamMovies(),
      loadMarathiMovies(),
      loadBengaliMovies(),
    ]);
  }

  // Load Indian Genre Catalogue
  Future<void> loadIndianGenreCatalogue() async {
    await Future.wait([
      loadBollywoodMasala(),
      loadSouthIndianAction(),
      loadMarathiCinema(),
    ]);
  }

  // Load Indian Streaming Platforms Catalogue
  Future<void> loadIndianStreamingCatalogue() async {
    await Future.wait([
      loadHotstarContent(),
      loadSonyLIVContent(),
      loadZee5Content(),
    ]);
  }

  // Individual load methods for regional languages
  Future<void> loadTamilMovies() async {
    _isLoadingTamilMovies = true;
    _tamilMoviesError = null;
    notifyListeners();

    try {
      _tamilMovies = await TMDBService.getTamilMovies(pages: 2);
      _tamilMoviesError = null;
    } catch (e) {
      _tamilMoviesError = 'Failed to load Tamil movies: $e';
      print('Error loading Tamil movies: $e');
    } finally {
      _isLoadingTamilMovies = false;
      notifyListeners();
    }
  }

  Future<void> loadTeluguMovies() async {
    _isLoadingTeluguMovies = true;
    _teluguMoviesError = null;
    notifyListeners();

    try {
      _teluguMovies = await TMDBService.getTeluguMovies(pages: 2);
      _teluguMoviesError = null;
    } catch (e) {
      _teluguMoviesError = 'Failed to load Telugu movies: $e';
      print('Error loading Telugu movies: $e');
    } finally {
      _isLoadingTeluguMovies = false;
      notifyListeners();
    }
  }

  Future<void> loadMalayalamMovies() async {
    _isLoadingMalayalamMovies = true;
    _malayalamMoviesError = null;
    notifyListeners();

    try {
      _malayalamMovies = await TMDBService.getMalayalamMovies(pages: 2);
      _malayalamMoviesError = null;
    } catch (e) {
      _malayalamMoviesError = 'Failed to load Malayalam movies: $e';
      print('Error loading Malayalam movies: $e');
    } finally {
      _isLoadingMalayalamMovies = false;
      notifyListeners();
    }
  }

  Future<void> loadMarathiMovies() async {
    _isLoadingMarathiMovies = true;
    _marathiMoviesError = null;
    notifyListeners();

    try {
      _marathiMovies = await TMDBService.getMarathiMovies(pages: 2);
      _marathiMoviesError = null;
    } catch (e) {
      _marathiMoviesError = 'Failed to load Marathi movies: $e';
      print('Error loading Marathi movies: $e');
    } finally {
      _isLoadingMarathiMovies = false;
      notifyListeners();
    }
  }

  Future<void> loadBengaliMovies() async {
    _isLoadingBengaliMovies = true;
    _bengaliMoviesError = null;
    notifyListeners();

    try {
      _bengaliMovies = await TMDBService.getBengaliMovies(pages: 2);
      _bengaliMoviesError = null;
    } catch (e) {
      _bengaliMoviesError = 'Failed to load Bengali movies: $e';
      print('Error loading Bengali movies: $e');
    } finally {
      _isLoadingBengaliMovies = false;
      notifyListeners();
    }
  }

  // Individual load methods for Indian genres
  Future<void> loadBollywoodMasala() async {
    _isLoadingBollywoodMasala = true;
    _bollywoodMasalaError = null;
    notifyListeners();

    try {
      _bollywoodMasala = await TMDBService.getBollywoodMasala(pages: 2);
      _bollywoodMasalaError = null;
    } catch (e) {
      _bollywoodMasalaError = 'Failed to load Bollywood Masala: $e';
      print('Error loading Bollywood Masala: $e');
    } finally {
      _isLoadingBollywoodMasala = false;
      notifyListeners();
    }
  }

  Future<void> loadSouthIndianAction() async {
    _isLoadingSouthIndianAction = true;
    _southIndianActionError = null;
    notifyListeners();

    try {
      _southIndianAction = await TMDBService.getSouthIndianAction(pages: 2);
      _southIndianActionError = null;
    } catch (e) {
      _southIndianActionError = 'Failed to load South Indian Action: $e';
      print('Error loading South Indian Action: $e');
    } finally {
      _isLoadingSouthIndianAction = false;
      notifyListeners();
    }
  }

  Future<void> loadMarathiCinema() async {
    _isLoadingMarathiCinema = true;
    _marathiCinemaError = null;
    notifyListeners();

    try {
      _marathiCinema = await TMDBService.getMarathiCinema(pages: 2);
      _marathiCinemaError = null;
    } catch (e) {
      _marathiCinemaError = 'Failed to load Marathi Cinema: $e';
      print('Error loading Marathi Cinema: $e');
    } finally {
      _isLoadingMarathiCinema = false;
      notifyListeners();
    }
  }

  // Individual load methods for Indian streaming platforms
  Future<void> loadHotstarContent() async {
    _isLoadingHotstarContent = true;
    _hotstarContentError = null;
    notifyListeners();

    try {
      _hotstarContent = await TMDBService.getHotstarContent(pages: 2);
      _hotstarContentError = null;
    } catch (e) {
      _hotstarContentError = 'Failed to load Hotstar content: $e';
      print('Error loading Hotstar content: $e');
    } finally {
      _isLoadingHotstarContent = false;
      notifyListeners();
    }
  }

  Future<void> loadSonyLIVContent() async {
    _isLoadingSonyLIVContent = true;
    _sonyLIVContentError = null;
    notifyListeners();

    try {
      _sonyLIVContent = await TMDBService.getSonyLIVContent(pages: 2);
      _sonyLIVContentError = null;
    } catch (e) {
      _sonyLIVContentError = 'Failed to load SonyLIV content: $e';
      print('Error loading SonyLIV content: $e');
    } finally {
      _isLoadingSonyLIVContent = false;
      notifyListeners();
    }
  }

  Future<void> loadZee5Content() async {
    _isLoadingZee5Content = true;
    _zee5ContentError = null;
    notifyListeners();

    try {
      _zee5Content = await TMDBService.getZee5Content(pages: 2);
      _zee5ContentError = null;
    } catch (e) {
      _zee5ContentError = 'Failed to load Zee5 content: $e';
      print('Error loading Zee5 content: $e');
    } finally {
      _isLoadingZee5Content = false;
      notifyListeners();
    }
  }

  // Refresh Bollywood catalogue
  Future<void> refreshBollywoodCatalogue() async {
    await loadBollywoodCatalogue();
  }

  // Refresh Korean catalogue
  Future<void> refreshKoreanCatalogue() async {
    await loadKoreanCatalogue();
  }

  // Refresh Netflix catalogue
  Future<void> refreshNetflixCatalogue() async {
    await loadNetflixCatalogue();
  }

  // Refresh Prime catalogue
  Future<void> refreshPrimeCatalogue() async {
    await loadPrimeCatalogue();
  }

  // Load popular now (most popular content)
  Future<void> loadPopularNow() async {
    _isLoadingPopular = true;
    _popularError = null;
    notifyListeners();

    try {
      // Try to get cached data first
      final cacheKey = CacheService.generateKey('popular_now');
      final cachedData = await CacheService.getCachedData(cacheKey);

      if (cachedData != null) {
        // Use cached data
        _popularNow = (cachedData['results'] as List)
            .map((json) => Media.fromJson(json))
            .toList();
        _popularNow = _filterAdultContent(_popularNow);
        _popularError = null;

        if (kDebugMode) {
          print('📱 Using cached popular data');
        }
      } else {
        // Fetch fresh data from API
        _popularNow = await TMDBService.getMostPopularHollywood(limit: 12);
        _popularNow = _filterAdultContent(_popularNow);

        // Cache the fresh data
        await CacheService.cacheData(cacheKey, {
          'results': _popularNow.map((media) => media.toJson()).toList(),
        });

        if (kDebugMode) {
          print('🌐 Fetched fresh popular data from API');
        }
      }

      _popularError = null;
    } catch (e) {
      _popularError = 'Failed to load popular content: $e';
      print('Error loading popular: $e');
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  // Load newly released in theaters
  Future<void> loadNewlyReleased() async {
    _isLoadingNewlyReleased = true;
    _newlyReleasedError = null;
    notifyListeners();

    try {
      // Try to get cached data first
      final cacheKey = CacheService.generateKey('newly_released');
      final cachedData = await CacheService.getCachedData(cacheKey);

      if (cachedData != null) {
        // Use cached data
        _newlyReleased = (cachedData['results'] as List)
            .map((json) => Media.fromJson(json))
            .toList();
        _newlyReleased = _filterAdultContent(_newlyReleased);
        _newlyReleasedError = null;

        if (kDebugMode) {
          print('📱 Using cached newly released data');
        }
      } else {
        // Fetch fresh data from API
        _newlyReleased = await TMDBService.getNowPlayingMovies(pages: 1);
        _newlyReleased = _filterAdultContent(_newlyReleased);

        // Cache the fresh data
        await CacheService.cacheData(cacheKey, {
          'results': _newlyReleased.map((media) => media.toJson()).toList(),
        });

        if (kDebugMode) {
          print('🌐 Fetched fresh newly released data from API');
        }
      }

      _newlyReleasedError = null;
    } catch (e) {
      _newlyReleasedError = 'Failed to load newly released movies: $e';
      print('Error loading newly released: $e');
    } finally {
      _isLoadingNewlyReleased = false;
      notifyListeners();
    }
  }

  // Load most popular
  Future<void> loadMostPopular() async {
    _isLoadingMostPopular = true;
    _mostPopularError = null;
    notifyListeners();

    try {
      // Try to get cached data first
      final cacheKey = CacheService.generateKey('most_popular');
      final cachedData = await CacheService.getCachedData(cacheKey);

      if (cachedData != null) {
        // Use cached data
        _mostPopular = (cachedData['results'] as List)
            .map((json) => Media.fromJson(json))
            .toList();
        _mostPopularError = null;

        if (kDebugMode) {
          print('📱 Using cached most popular data');
        }
      } else {
        // Fetch fresh data from API
        _mostPopular = await TMDBService.getMostViewed(limit: 12);

        // Cache the fresh data
        await CacheService.cacheData(cacheKey, {
          'results': _mostPopular.map((media) => media.toJson()).toList(),
        });

        if (kDebugMode) {
          print('🌐 Fetched fresh most popular data from API');
        }
      }

      _mostPopularError = null;
    } catch (e) {
      _mostPopularError = 'Failed to load most popular content: $e';
      print('Error loading most popular: $e');
    } finally {
      _isLoadingMostPopular = false;
      notifyListeners();
    }
  }

  // Load top rated movies
  Future<void> loadTopRatedMovies() async {
    _isLoadingTopRatedMovies = true;
    _topRatedMoviesError = null;
    notifyListeners();

    try {
      _topRatedMovies = await TMDBService.getTopRatedMovies(pages: 2);
      _topRatedMoviesError = null;
    } catch (e) {
      _topRatedMoviesError = 'Failed to load top rated movies: $e';
      print('Error loading top rated movies: $e');
    } finally {
      _isLoadingTopRatedMovies = false;
      notifyListeners();
    }
  }

  // Load top rated TV shows
  Future<void> loadTopRatedTvShows() async {
    _isLoadingTopRatedTvShows = true;
    _topRatedTvShowsError = null;
    notifyListeners();

    try {
      _topRatedTvShows = await TMDBService.getTopRatedTvShows(pages: 1);
      _topRatedTvShowsError = null;
    } catch (e) {
      _topRatedTvShowsError = 'Failed to load top rated TV shows: $e';
      print('Error loading top rated TV shows: $e');
    } finally {
      _isLoadingTopRatedTvShows = false;
      notifyListeners();
    }
  }

  // Load action & adventure movies
  Future<void> loadActionAdventure() async {
    _isLoadingActionAdventure = true;
    _actionAdventureError = null;
    notifyListeners();

    try {
      _actionAdventure =
          await TMDBService.getIndianMoviesByGenre('28,12', pages: 2);
      _actionAdventureError = null;
    } catch (e) {
      _actionAdventureError = 'Failed to load action & adventure movies: $e';
      print('Error loading action & adventure: $e');
    } finally {
      _isLoadingActionAdventure = false;
      notifyListeners();
    }
  }

  // Load comedy movies
  Future<void> loadComedy() async {
    _isLoadingComedy = true;
    _comedyError = null;
    notifyListeners();

    try {
      _comedy = await TMDBService.getIndianMoviesByGenre('35', pages: 2);
      _comedyError = null;
    } catch (e) {
      _comedyError = 'Failed to load comedy movies: $e';
      print('Error loading comedy: $e');
    } finally {
      _isLoadingComedy = false;
      notifyListeners();
    }
  }

  // Load sci-fi & fantasy movies
  Future<void> loadScifiFantasy() async {
    _isLoadingScifiFantasy = true;
    _scifiFantasyError = null;
    notifyListeners();

    try {
      _scifiFantasy =
          await TMDBService.getIndianMoviesByGenre('878,14', pages: 2);
      _scifiFantasyError = null;
    } catch (e) {
      _scifiFantasyError = 'Failed to load sci-fi & fantasy movies: $e';
      print('Error loading sci-fi & fantasy: $e');
    } finally {
      _isLoadingScifiFantasy = false;
      notifyListeners();
    }
  }

  // Load horror movies
  Future<void> loadHorror() async {
    _isLoadingHorror = true;
    _horrorError = null;
    notifyListeners();

    try {
      _horror = await TMDBService.getIndianMoviesByGenre('27', pages: 2);
      _horrorError = null;
    } catch (e) {
      _horrorError = 'Failed to load horror movies: $e';
      print('Error loading horror: $e');
    } finally {
      _isLoadingHorror = false;
      notifyListeners();
    }
  }

  // Load thriller movies
  Future<void> loadThriller() async {
    _isLoadingThriller = true;
    _thrillerError = null;
    notifyListeners();

    try {
      _thriller = await TMDBService.getIndianMoviesByGenre('53', pages: 2);
      _thrillerError = null;
    } catch (e) {
      _thrillerError = 'Failed to load thriller movies: $e';
      print('Error loading thriller: $e');
    } finally {
      _isLoadingThriller = false;
      notifyListeners();
    }
  }

  // Indian content methods for Hollywood screen
  Future<void> loadIndianActionAdventure() async {
    _isLoadingActionAdventure = true;
    _actionAdventureError = null;
    notifyListeners();

    try {
      _actionAdventure =
          await TMDBService.getIndianMoviesByGenre('28,12', pages: 2);
      _actionAdventureError = null;
    } catch (e) {
      _actionAdventureError =
          'Failed to load Indian action & adventure movies: $e';
      print('Error loading Indian action & adventure: $e');
    } finally {
      _isLoadingActionAdventure = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianComedy() async {
    _isLoadingComedy = true;
    _comedyError = null;
    notifyListeners();

    try {
      _comedy = await TMDBService.getIndianMoviesByGenre('35', pages: 2);
      _comedyError = null;
    } catch (e) {
      _comedyError = 'Failed to load Indian comedy movies: $e';
      print('Error loading Indian comedy: $e');
    } finally {
      _isLoadingComedy = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianScifiFantasy() async {
    _isLoadingScifiFantasy = true;
    _scifiFantasyError = null;
    notifyListeners();

    try {
      _scifiFantasy =
          await TMDBService.getIndianMoviesByGenre('878,14', pages: 2);
      _scifiFantasyError = null;
    } catch (e) {
      _scifiFantasyError = 'Failed to load Indian sci-fi & fantasy movies: $e';
      print('Error loading Indian sci-fi & fantasy: $e');
    } finally {
      _isLoadingScifiFantasy = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianHorror() async {
    _isLoadingHorror = true;
    _horrorError = null;
    notifyListeners();

    try {
      _horror = await TMDBService.getIndianMoviesByGenre('27', pages: 2);
      _horrorError = null;
    } catch (e) {
      _horrorError = 'Failed to load Indian horror movies: $e';
      print('Error loading Indian horror: $e');
    } finally {
      _isLoadingHorror = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianThriller() async {
    _isLoadingThriller = true;
    _thrillerError = null;
    notifyListeners();

    try {
      _thriller = await TMDBService.getIndianMoviesByGenre('53', pages: 2);
      _thrillerError = null;
    } catch (e) {
      _thrillerError = 'Failed to load Indian thriller movies: $e';
      print('Error loading Indian thriller: $e');
    } finally {
      _isLoadingThriller = false;
      notifyListeners();
    }
  }

  // Load drama movies
  Future<void> loadDrama() async {
    _isLoadingDrama = true;
    _dramaError = null;
    notifyListeners();

    try {
      _drama = await TMDBService.getIndianMoviesByGenre('18', pages: 2);
      _dramaError = null;
    } catch (e) {
      _dramaError = 'Failed to load drama movies: $e';
      print('Error loading drama: $e');
    } finally {
      _isLoadingDrama = false;
      notifyListeners();
    }
  }

  // Load romance movies
  Future<void> loadRomance() async {
    _isLoadingRomance = true;
    _romanceError = null;
    notifyListeners();

    try {
      _romance = await TMDBService.getIndianMoviesByGenre('10749', pages: 2);
      _romanceError = null;
    } catch (e) {
      _romanceError = 'Failed to load romance movies: $e';
      print('Error loading romance: $e');
    } finally {
      _isLoadingRomance = false;
      notifyListeners();
    }
  }

  // Load animation movies
  Future<void> loadAnimation() async {
    _isLoadingAnimation = true;
    _animationError = null;
    notifyListeners();

    try {
      _animation = await TMDBService.getIndianMoviesByGenre('16', pages: 2);
      _animationError = null;
    } catch (e) {
      _animationError = 'Failed to load animation movies: $e';
      print('Error loading animation: $e');
    } finally {
      _isLoadingAnimation = false;
      notifyListeners();
    }
  }

  // Load family movies
  Future<void> loadFamily() async {
    _isLoadingFamily = true;
    _familyError = null;
    notifyListeners();

    try {
      _family = await TMDBService.getIndianMoviesByGenre('10751', pages: 2);
      _familyError = null;
    } catch (e) {
      _familyError = 'Failed to load family movies: $e';
      print('Error loading family: $e');
    } finally {
      _isLoadingFamily = false;
      notifyListeners();
    }
  }

  // Load documentary movies
  Future<void> loadDocumentary() async {
    _isLoadingDocumentary = true;
    _documentaryError = null;
    notifyListeners();

    try {
      _documentary = await TMDBService.getIndianMoviesByGenre('99', pages: 2);
      _documentaryError = null;
    } catch (e) {
      _documentaryError = 'Failed to load documentary movies: $e';
      print('Error loading documentary: $e');
    } finally {
      _isLoadingDocumentary = false;
      notifyListeners();
    }
  }

  // Load crime movies
  Future<void> loadCrime() async {
    _isLoadingCrime = true;
    _crimeError = null;
    notifyListeners();

    try {
      _crime = await TMDBService.discoverMoviesByGenre('80', pages: 2);
      _crimeError = null;
    } catch (e) {
      _crimeError = 'Failed to load crime movies: $e';
      print('Error loading crime: $e');
    } finally {
      _isLoadingCrime = false;
      notifyListeners();
    }
  }

  // Indian content methods for Hollywood screen (continued)
  Future<void> loadIndianDrama() async {
    _isLoadingDrama = true;
    _dramaError = null;
    notifyListeners();

    try {
      _drama = await TMDBService.getIndianMoviesByGenre('18', pages: 2);
      _dramaError = null;
    } catch (e) {
      _dramaError = 'Failed to load Indian drama movies: $e';
      print('Error loading Indian drama: $e');
    } finally {
      _isLoadingDrama = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianRomance() async {
    _isLoadingRomance = true;
    _romanceError = null;
    notifyListeners();

    try {
      _romance = await TMDBService.getIndianMoviesByGenre('10749', pages: 2);
      _romanceError = null;
    } catch (e) {
      _romanceError = 'Failed to load Indian romance movies: $e';
      print('Error loading Indian romance: $e');
    } finally {
      _isLoadingRomance = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianAnimation() async {
    _isLoadingAnimation = true;
    _animationError = null;
    notifyListeners();

    try {
      _animation = await TMDBService.getIndianMoviesByGenre('16', pages: 2);
      _animationError = null;
    } catch (e) {
      _animationError = 'Failed to load Indian animation movies: $e';
      print('Error loading Indian animation: $e');
    } finally {
      _isLoadingAnimation = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianFamily() async {
    _isLoadingFamily = true;
    _familyError = null;
    notifyListeners();

    try {
      _family = await TMDBService.getIndianMoviesByGenre('10751', pages: 2);
      _familyError = null;
    } catch (e) {
      _familyError = 'Failed to load Indian family movies: $e';
      print('Error loading Indian family: $e');
    } finally {
      _isLoadingFamily = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianDocumentary() async {
    _isLoadingDocumentary = true;
    _documentaryError = null;
    notifyListeners();

    try {
      _documentary = await TMDBService.getIndianMoviesByGenre('99', pages: 2);
      _documentaryError = null;
    } catch (e) {
      _documentaryError = 'Failed to load Indian documentary movies: $e';
      print('Error loading Indian documentary: $e');
    } finally {
      _isLoadingDocumentary = false;
      notifyListeners();
    }
  }

  Future<void> loadIndianCrime() async {
    _isLoadingCrime = true;
    _crimeError = null;
    notifyListeners();

    try {
      _crime = await TMDBService.getIndianMoviesByGenre('80', pages: 2);
      _crimeError = null;
    } catch (e) {
      _crimeError = 'Failed to load Indian crime movies: $e';
      print('Error loading Indian crime: $e');
    } finally {
      _isLoadingCrime = false;
      notifyListeners();
    }
  }

  // Load mystery movies
  Future<void> loadMystery() async {
    _isLoadingMystery = true;
    _mysteryError = null;
    notifyListeners();

    try {
      _mystery = await TMDBService.discoverMoviesByGenre('9648', pages: 2);
      _mysteryError = null;
    } catch (e) {
      _mysteryError = 'Failed to load mystery movies: $e';
      print('Error loading mystery: $e');
    } finally {
      _isLoadingMystery = false;
      notifyListeners();
    }
  }

  // Load war movies
  Future<void> loadWar() async {
    _isLoadingWar = true;
    _warError = null;
    notifyListeners();

    try {
      _war = await TMDBService.discoverMoviesByGenre('10752', pages: 2);
      _warError = null;
    } catch (e) {
      _warError = 'Failed to load war movies: $e';
      print('Error loading war: $e');
    } finally {
      _isLoadingWar = false;
      notifyListeners();
    }
  }

  // Load western movies
  Future<void> loadWestern() async {
    _isLoadingWestern = true;
    _westernError = null;
    notifyListeners();

    try {
      _western = await TMDBService.discoverMoviesByGenre('37', pages: 2);
      _westernError = null;
    } catch (e) {
      _westernError = 'Failed to load western movies: $e';
      print('Error loading western: $e');
    } finally {
      _isLoadingWestern = false;
      notifyListeners();
    }
  }

  // Load music movies
  Future<void> loadMusic() async {
    _isLoadingMusic = true;
    _musicError = null;
    notifyListeners();

    try {
      _music = await TMDBService.discoverMoviesByGenre('13', pages: 2);
      _musicError = null;
    } catch (e) {
      _musicError = 'Failed to load music movies: $e';
      print('Error loading music: $e');
    } finally {
      _isLoadingMusic = false;
      notifyListeners();
    }
  }

  // Load history movies
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      _history = await TMDBService.discoverMoviesByGenre('36', pages: 2);
      _historyError = null;
    } catch (e) {
      _historyError = 'Failed to load history movies: $e';
      print('Error loading history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Load upcoming movies
  Future<void> loadUpcoming() async {
    _isLoadingUpcoming = true;
    _upcomingError = null;
    notifyListeners();

    try {
      _upcoming = await TMDBService.fetchCustomData('/movie/upcoming', {
        'page': '1',
      });
      _upcomingError = null;
    } catch (e) {
      _upcomingError = 'Failed to load upcoming movies: $e';
      print('Error loading upcoming: $e');
    } finally {
      _isLoadingUpcoming = false;
      notifyListeners();
    }
  }

  // Load award winners
  Future<void> loadAwardWinners() async {
    _isLoadingAwardWinners = true;
    _awardWinnersError = null;
    notifyListeners();

    try {
      // High-rated movies that are likely award winners
      _awardWinners = await TMDBService.fetchCustomData('/discover/movie', {
        'vote_average.gte': '8.0',
        'vote_count.gte': '1000',
        'sort_by': 'vote_average.desc',
        'page': '1',
      });
      _awardWinnersError = null;
    } catch (e) {
      _awardWinnersError = 'Failed to load award winners: $e';
      print('Error loading award winners: $e');
    } finally {
      _isLoadingAwardWinners = false;
      notifyListeners();
    }
  }

  // Load indie films
  Future<void> loadIndie() async {
    _isLoadingIndie = true;
    _indieError = null;
    notifyListeners();

    try {
      // Independent films with lower budget indicators
      _indie = await TMDBService.fetchCustomData('/discover/movie', {
        'with_keywords': '210024', // Independent film keyword
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _indieError = null;
    } catch (e) {
      _indieError = 'Failed to load indie films: $e';
      print('Error loading indie: $e');
    } finally {
      _isLoadingIndie = false;
      notifyListeners();
    }
  }

  // Load foreign films
  Future<void> loadForeign() async {
    _isLoadingForeign = true;
    _foreignError = null;
    notifyListeners();

    try {
      // Non-English language films
      _foreign = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': '!en',
        'vote_count.gte': '100',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _foreignError = null;
    } catch (e) {
      _foreignError = 'Failed to load foreign films: $e';
      print('Error loading foreign: $e');
    } finally {
      _isLoadingForeign = false;
      notifyListeners();
    }
  }

  // Load classic movies
  Future<void> loadClassics() async {
    _isLoadingClassics = true;
    _classicsError = null;
    notifyListeners();

    try {
      // Classic movies before 1980
      _classics = await TMDBService.fetchCustomData('/discover/movie', {
        'primary_release_date.lte': '1980-12-31',
        'vote_count.gte': '500',
        'sort_by': 'vote_average.desc',
        'page': '1',
      });
      _classicsError = null;
    } catch (e) {
      _classicsError = 'Failed to load classics: $e';
      print('Error loading classics: $e');
    } finally {
      _isLoadingClassics = false;
      notifyListeners();
    }
  }

  // Load teen movies
  Future<void> loadTeen() async {
    _isLoadingTeen = true;
    _teenError = null;
    notifyListeners();

    try {
      // Teen-oriented movies
      _teen = await TMDBService.fetchCustomData('/discover/movie', {
        'with_keywords': '210024', // Teen movie keyword
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _teenError = null;
    } catch (e) {
      _teenError = 'Failed to load teen movies: $e';
      print('Error loading teen: $e');
    } finally {
      _isLoadingTeen = false;
      notifyListeners();
    }
  }

  // Load superhero movies
  Future<void> loadSuperheroMovies() async {
    _isLoadingSuperheroMovies = true;
    notifyListeners();

    try {
      _superheroMovies = await TMDBService.fetchCustomData('/discover/movie', {
        'with_keywords': '180547', // Superhero keyword
        'vote_count.gte': '100',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading superhero movies: $e');
    } finally {
      _isLoadingSuperheroMovies = false;
      notifyListeners();
    }
  }

  // Load musical movies
  Future<void> loadMusicalMovies() async {
    _isLoadingMusicalMovies = true;
    notifyListeners();

    try {
      _musicalMovies =
          await TMDBService.discoverMoviesByGenre('10402', pages: 1);
    } catch (e) {
      print('Error loading musical movies: $e');
    } finally {
      _isLoadingMusicalMovies = false;
      notifyListeners();
    }
  }

  // Load sports movies
  Future<void> loadSportsMovies() async {
    _isLoadingSportsMovies = true;
    notifyListeners();

    try {
      _sportsMovies = await TMDBService.fetchCustomData('/discover/movie', {
        'with_keywords': '180547', // Sports keyword
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading sports movies: $e');
    } finally {
      _isLoadingSportsMovies = false;
      notifyListeners();
    }
  }

  // Load biographical movies
  Future<void> loadBiographicalMovies() async {
    _isLoadingBiographicalMovies = true;
    notifyListeners();

    try {
      _biographicalMovies =
          await TMDBService.fetchCustomData('/discover/movie', {
        'with_keywords': '968', // Biography keyword
        'vote_count.gte': '100',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading biographical movies: $e');
    } finally {
      _isLoadingBiographicalMovies = false;
      notifyListeners();
    }
  }

  // Load spy thrillers
  Future<void> loadSpyThrillers() async {
    _isLoadingSpyThrillers = true;
    notifyListeners();

    try {
      _spyThrillers = await TMDBService.fetchCustomData('/discover/movie', {
        'with_keywords': '180547', // Spy keyword
        'vote_count.gte': '50',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading spy thrillers: $e');
    } finally {
      _isLoadingSpyThrillers = false;
      notifyListeners();
    }
  }

  // Load latest Bollywood
  Future<void> loadLatestBollywood() async {
    _isLoadingLatestBollywood = true;
    _latestBollywoodError = null;
    notifyListeners();

    try {
      // Latest Bollywood releases with Hindi language and Indian region
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'sort_by': 'primary_release_date.desc',
        'vote_count.gte': '25',
        'page': '1',
      });
      _latestBollywood = results;
      _latestBollywoodError = null;
    } catch (e) {
      _latestBollywoodError = 'Failed to load latest Bollywood: $e';
      print('Error loading latest Bollywood: $e');
    } finally {
      _isLoadingLatestBollywood = false;
      notifyListeners();
    }
  }

  // Load classics Bollywood
  Future<void> loadClassicsBollywood() async {
    _isLoadingClassicsBollywood = true;
    _classicsBollywoodError = null;
    notifyListeners();

    try {
      // Top-rated Bollywood classics before 2000
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'primary_release_date.lte': '2000-12-31',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '50',
        'page': '1',
      });
      _classicsBollywood = results;
      _classicsBollywoodError = null;
    } catch (e) {
      _classicsBollywoodError = 'Failed to load classics Bollywood: $e';
      print('Error loading classics Bollywood: $e');
    } finally {
      _isLoadingClassicsBollywood = false;
      notifyListeners();
    }
  }

  // Load Netflix Bollywood
  Future<void> loadNetflixBollywood() async {
    _isLoadingNetflixBollywood = true;
    _netflixBollywoodError = null;
    notifyListeners();

    try {
      // Netflix Bollywood content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'vote_count.gte': '25',
        'page': '1',
      });
      _netflixBollywood = results;
      _netflixBollywoodError = null;
    } catch (e) {
      _netflixBollywoodError = 'Failed to load Netflix Bollywood: $e';
      print('Error loading Netflix Bollywood: $e');
    } finally {
      _isLoadingNetflixBollywood = false;
      notifyListeners();
    }
  }

  // Load Prime Bollywood
  Future<void> loadPrimeBollywood() async {
    _isLoadingPrimeBollywood = true;
    _primeBollywoodError = null;
    notifyListeners();

    try {
      // Amazon Prime Bollywood content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'vote_count.gte': '25',
        'page': '1',
      });
      _primeBollywood = results;
      _primeBollywoodError = null;
    } catch (e) {
      _primeBollywoodError = 'Failed to load Prime Bollywood: $e';
      print('Error loading Prime Bollywood: $e');
    } finally {
      _isLoadingPrimeBollywood = false;
      notifyListeners();
    }
  }

  // Load Action Bollywood
  Future<void> loadActionBollywood() async {
    _isLoadingActionBollywood = true;
    _actionBollywoodError = null;
    notifyListeners();

    try {
      // Action Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '28',
        'vote_count.gte': '25',
        'page': '1',
      });
      _actionBollywood = results;
      _actionBollywoodError = null;
    } catch (e) {
      _actionBollywoodError = 'Failed to load Action Bollywood: $e';
      print('Error loading Action Bollywood: $e');
    } finally {
      _isLoadingActionBollywood = false;
      notifyListeners();
    }
  }

  // Load Romance Bollywood
  Future<void> loadRomanceBollywood() async {
    _isLoadingRomanceBollywood = true;
    _romanceBollywoodError = null;
    notifyListeners();

    try {
      // Romance Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '10749',
        'vote_count.gte': '25',
        'page': '1',
      });
      _romanceBollywood = results;
      _romanceBollywoodError = null;
    } catch (e) {
      _romanceBollywoodError = 'Failed to load Romance Bollywood: $e';
      print('Error loading Romance Bollywood: $e');
    } finally {
      _isLoadingRomanceBollywood = false;
      notifyListeners();
    }
  }

  // Load Thriller Bollywood
  Future<void> loadThrillerBollywood() async {
    _isLoadingThrillerBollywood = true;
    _thrillerBollywoodError = null;
    notifyListeners();

    try {
      // Thriller Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '53',
        'vote_count.gte': '25',
        'page': '1',
      });
      _thrillerBollywood = results;
      _thrillerBollywoodError = null;
    } catch (e) {
      _thrillerBollywoodError = 'Failed to load Thriller Bollywood: $e';
      print('Error loading Thriller Bollywood: $e');
    } finally {
      _isLoadingThrillerBollywood = false;
      notifyListeners();
    }
  }

  // Load Popular Hindi TV
  Future<void> loadPopularHindiTv() async {
    _isLoadingPopularHindiTv = true;
    _popularHindiTvError = null;
    notifyListeners();

    try {
      // Popular Hindi TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'hi',
        'region': 'IN',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _popularHindiTv = results;
      _popularHindiTvError = null;
    } catch (e) {
      _popularHindiTvError = 'Failed to load Popular Hindi TV: $e';
      print('Error loading Popular Hindi TV: $e');
    } finally {
      _isLoadingPopularHindiTv = false;
      notifyListeners();
    }
  }

  // Load Top Rated Hindi TV
  Future<void> loadTopRatedHindiTv() async {
    _isLoadingTopRatedHindiTv = true;
    _topRatedHindiTvError = null;
    notifyListeners();

    try {
      // Top-rated Hindi TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'hi',
        'region': 'IN',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '20',
        'page': '1',
      });
      _topRatedHindiTv = results;
      _topRatedHindiTvError = null;
    } catch (e) {
      _topRatedHindiTvError = 'Failed to load Top Rated Hindi TV: $e';
      print('Error loading Top Rated Hindi TV: $e');
    } finally {
      _isLoadingTopRatedHindiTv = false;
      notifyListeners();
    }
  }

  // Load New Releases Bollywood (2024-2025)
  Future<void> loadNewReleasesBollywood() async {
    _isLoadingNewReleasesBollywood = true;
    _newReleasesBollywoodError = null;
    notifyListeners();

    try {
      // Latest Bollywood releases from 2024 onwards
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'primary_release_date.gte': '2024-01-01',
        'sort_by': 'primary_release_date.desc',
        'vote_count.gte': '20',
        'page': '1',
      });
      _newReleasesBollywood = results;
      _newReleasesBollywoodError = null;
    } catch (e) {
      _newReleasesBollywoodError = 'Failed to load new releases Bollywood: $e';
      print('Error loading new releases Bollywood: $e');
    } finally {
      _isLoadingNewReleasesBollywood = false;
      notifyListeners();
    }
  }

  // Load Blockbuster Hits Bollywood
  Future<void> loadBlockbusterHitsBollywood() async {
    _isLoadingBlockbusterHitsBollywood = true;
    _blockbusterHitsBollywoodError = null;
    notifyListeners();

    try {
      // High-grossing Bollywood blockbusters
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'sort_by': 'revenue.desc',
        'vote_count.gte': '100',
        'page': '1',
      });
      _blockbusterHitsBollywood = results;
      _blockbusterHitsBollywoodError = null;
    } catch (e) {
      _blockbusterHitsBollywoodError =
          'Failed to load blockbuster hits Bollywood: $e';
      print('Error loading blockbuster hits Bollywood: $e');
    } finally {
      _isLoadingBlockbusterHitsBollywood = false;
      notifyListeners();
    }
  }

  // Load Critically Acclaimed Bollywood
  Future<void> loadCriticallyAcclaimedBollywood() async {
    _isLoadingCriticallyAcclaimedBollywood = true;
    _criticallyAcclaimedBollywoodError = null;
    notifyListeners();

    try {
      // Critically acclaimed Bollywood films
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '50',
        'vote_average.gte': '7.0',
        'page': '1',
      });
      _criticallyAcclaimedBollywood = results;
      _criticallyAcclaimedBollywoodError = null;
    } catch (e) {
      _criticallyAcclaimedBollywoodError =
          'Failed to load critically acclaimed Bollywood: $e';
      print('Error loading critically acclaimed Bollywood: $e');
    } finally {
      _isLoadingCriticallyAcclaimedBollywood = false;
      notifyListeners();
    }
  }

  // Load Family Entertainment Bollywood
  Future<void> loadFamilyEntertainmentBollywood() async {
    _isLoadingFamilyEntertainmentBollywood = true;
    _familyEntertainmentBollywoodError = null;
    notifyListeners();

    try {
      // Family-friendly Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '10751',
        'vote_count.gte': '25',
        'page': '1',
      });
      _familyEntertainmentBollywood = results;
      _familyEntertainmentBollywoodError = null;
    } catch (e) {
      _familyEntertainmentBollywoodError =
          'Failed to load family entertainment Bollywood: $e';
      print('Error loading family entertainment Bollywood: $e');
    } finally {
      _isLoadingFamilyEntertainmentBollywood = false;
      notifyListeners();
    }
  }

  // Load Comedy Gold Bollywood
  Future<void> loadComedyGoldBollywood() async {
    _isLoadingComedyGoldBollywood = true;
    _comedyGoldBollywoodError = null;
    notifyListeners();

    try {
      // Comedy Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '35',
        'vote_count.gte': '25',
        'page': '1',
      });
      _comedyGoldBollywood = results;
      _comedyGoldBollywoodError = null;
    } catch (e) {
      _comedyGoldBollywoodError = 'Failed to load comedy gold Bollywood: $e';
      print('Error loading comedy gold Bollywood: $e');
    } finally {
      _isLoadingComedyGoldBollywood = false;
      notifyListeners();
    }
  }

  // Load Action Thrillers Bollywood
  Future<void> loadActionThrillersBollywood() async {
    _isLoadingActionThrillersBollywood = true;
    _actionThrillersBollywoodError = null;
    notifyListeners();

    try {
      // Action thriller Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '28,53',
        'vote_count.gte': '25',
        'page': '1',
      });
      _actionThrillersBollywood = results;
      _actionThrillersBollywoodError = null;
    } catch (e) {
      _actionThrillersBollywoodError =
          'Failed to load action thrillers Bollywood: $e';
      print('Error loading action thrillers Bollywood: $e');
    } finally {
      _isLoadingActionThrillersBollywood = false;
      notifyListeners();
    }
  }

  // Load Romantic Dramas Bollywood
  Future<void> loadRomanticDramasBollywood() async {
    _isLoadingRomanticDramasBollywood = true;
    _romanticDramasBollywoodError = null;
    notifyListeners();

    try {
      // Romantic drama Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '10749,18',
        'vote_count.gte': '25',
        'page': '1',
      });
      _romanticDramasBollywood = results;
      _romanticDramasBollywoodError = null;
    } catch (e) {
      _romanticDramasBollywoodError =
          'Failed to load romantic dramas Bollywood: $e';
      print('Error loading romantic dramas Bollywood: $e');
    } finally {
      _isLoadingRomanticDramasBollywood = false;
      notifyListeners();
    }
  }

  // Load Mystery & Crime Bollywood
  Future<void> loadMysteryCrimeBollywood() async {
    _isLoadingMysteryCrimeBollywood = true;
    _mysteryCrimeBollywoodError = null;
    notifyListeners();

    try {
      // Mystery and crime Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '80,9648',
        'vote_count.gte': '25',
        'page': '1',
      });
      _mysteryCrimeBollywood = results;
      _mysteryCrimeBollywoodError = null;
    } catch (e) {
      _mysteryCrimeBollywoodError =
          'Failed to load mystery & crime Bollywood: $e';
      print('Error loading mystery & crime Bollywood: $e');
    } finally {
      _isLoadingMysteryCrimeBollywood = false;
      notifyListeners();
    }
  }

  // Load Biographical Bollywood
  Future<void> loadBiographicalBollywood() async {
    _isLoadingBiographicalBollywood = true;
    _biographicalBollywoodError = null;
    notifyListeners();

    try {
      // Biographical Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '36',
        'vote_count.gte': '25',
        'page': '1',
      });
      _biographicalBollywood = results;
      _biographicalBollywoodError = null;
    } catch (e) {
      _biographicalBollywoodError = 'Failed to load biographical Bollywood: $e';
      print('Error loading biographical Bollywood: $e');
    } finally {
      _isLoadingBiographicalBollywood = false;
      notifyListeners();
    }
  }

  // Load Web Series Bollywood
  Future<void> loadWebSeriesBollywood() async {
    _isLoadingWebSeriesBollywood = true;
    _webSeriesBollywoodError = null;
    notifyListeners();

    try {
      // Hindi web series and TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'hi',
        'region': 'IN',
        'sort_by': 'popularity.desc',
        'vote_count.gte': '20',
        'page': '1',
      });
      _webSeriesBollywood = results;
      _webSeriesBollywoodError = null;
    } catch (e) {
      _webSeriesBollywoodError = 'Failed to load web series Bollywood: $e';
      print('Error loading web series Bollywood: $e');
    } finally {
      _isLoadingWebSeriesBollywood = false;
      notifyListeners();
    }
  }

  // Load Upcoming Bollywood
  Future<void> loadUpcomingBollywood() async {
    _isLoadingUpcomingBollywood = true;
    _upcomingBollywoodError = null;
    notifyListeners();

    try {
      // Upcoming Bollywood releases
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'primary_release_date.gte': '2025-01-01',
        'sort_by': 'primary_release_date.asc',
        'page': '1',
      });
      _upcomingBollywood = results;
      _upcomingBollywoodError = null;
    } catch (e) {
      _upcomingBollywoodError = 'Failed to load upcoming Bollywood: $e';
      print('Error loading upcoming Bollywood: $e');
    } finally {
      _isLoadingUpcomingBollywood = false;
      notifyListeners();
    }
  }

  // Load Award Winners Bollywood
  Future<void> loadAwardWinnersBollywood() async {
    _isLoadingAwardWinnersBollywood = true;
    _awardWinnersBollywoodError = null;
    notifyListeners();

    try {
      // Award-winning Bollywood movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '100',
        'vote_average.gte': '7.5',
        'page': '1',
      });
      _awardWinnersBollywood = results;
      _awardWinnersBollywoodError = null;
    } catch (e) {
      _awardWinnersBollywoodError =
          'Failed to load award winners Bollywood: $e';
      print('Error loading award winners Bollywood: $e');
    } finally {
      _isLoadingAwardWinnersBollywood = false;
      notifyListeners();
    }
  }

  // Load masala movies
  Future<void> loadMasalaMovies() async {
    _isLoadingMasalaMovies = true;
    notifyListeners();

    try {
      _masalaMovies = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_keywords': '180547', // Masala keyword
        'vote_count.gte': '25',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading masala movies: $e');
    } finally {
      _isLoadingMasalaMovies = false;
      notifyListeners();
    }
  }

  // Load patriotic movies
  Future<void> loadPatrioticMovies() async {
    _isLoadingPatrioticMovies = true;
    notifyListeners();

    try {
      _patrioticMovies = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_keywords': '180547', // Patriotic keyword
        'vote_count.gte': '25',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading patriotic movies: $e');
    } finally {
      _isLoadingPatrioticMovies = false;
      notifyListeners();
    }
  }

  // Load social dramas
  Future<void> loadSocialDramas() async {
    _isLoadingSocialDramas = true;
    notifyListeners();

    try {
      _socialDramas = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '18', // Drama genre
        'vote_count.gte': '25',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading social dramas: $e');
    } finally {
      _isLoadingSocialDramas = false;
      notifyListeners();
    }
  }

  // Load comedy dramas
  Future<void> loadComedyDramas() async {
    _isLoadingComedyDramas = true;
    notifyListeners();

    try {
      _comedyDramas = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '35,18', // Comedy and Drama genres
        'vote_count.gte': '25',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading comedy dramas: $e');
    } finally {
      _isLoadingComedyDramas = false;
      notifyListeners();
    }
  }

  // Load action comedies
  Future<void> loadActionComedies() async {
    _isLoadingActionComedies = true;
    notifyListeners();

    try {
      _actionComedies = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi',
        'region': 'IN',
        'with_genres': '28,35', // Action and Comedy genres
        'vote_count.gte': '25',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading action comedies: $e');
    } finally {
      _isLoadingActionComedies = false;
      notifyListeners();
    }
  }

  // Load Hindi TV Shows
  Future<void> loadTvShowsHindi() async {
    _isLoadingTvShowsHindi = true;
    notifyListeners();

    try {
      _tvShowsHindi = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'hi',
        'with_origin_country': 'IN',
        'vote_count.gte': '25',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading Hindi TV shows: $e');
    } finally {
      _isLoadingTvShowsHindi = false;
      notifyListeners();
    }
  }

  // Load Reality Shows Hindi
  Future<void> loadRealityShowsHindi() async {
    _isLoadingRealityShowsHindi = true;
    notifyListeners();

    try {
      _realityShowsHindi = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'hi',
        'with_origin_country': 'IN',
        'with_genres': '10764', // Reality genre
        'vote_count.gte': '25',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
    } catch (e) {
      print('Error loading Hindi reality shows: $e');
    } finally {
      _isLoadingRealityShowsHindi = false;
      notifyListeners();
    }
  }

  // Load latest Korean
  Future<void> loadLatestKorean() async {
    _isLoadingLatestKorean = true;
    _latestKoreanError = null;
    notifyListeners();

    try {
      // Latest Korean releases with Korean language and Korean region
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'sort_by': 'primary_release_date.desc',
        'vote_count.gte': '25',
        'page': '1',
      });
      _latestKorean = results;
      _latestKoreanError = null;
    } catch (e) {
      _latestKoreanError = 'Failed to load latest Korean: $e';
      print('Error loading latest Korean: $e');
    } finally {
      _isLoadingLatestKorean = false;
      notifyListeners();
    }
  }

  // Load top rated Korean
  Future<void> loadTopRatedKorean() async {
    _isLoadingTopRatedKorean = true;
    _topRatedKoreanError = null;
    notifyListeners();

    try {
      // Top-rated Korean movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '25',
        'page': '1',
      });
      _topRatedKorean = results;
      _topRatedKoreanError = null;
    } catch (e) {
      _topRatedKoreanError = 'Failed to load top rated Korean: $e';
      print('Error loading top rated Korean: $e');
    } finally {
      _isLoadingTopRatedKorean = false;
      notifyListeners();
    }
  }

  // Load action Korean
  Future<void> loadActionKorean() async {
    _isLoadingActionKorean = true;
    _actionKoreanError = null;
    notifyListeners();

    try {
      // Action Korean movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'with_genres': '28',
        'vote_count.gte': '25',
        'page': '1',
      });
      _actionKorean = results;
      _actionKoreanError = null;
    } catch (e) {
      _actionKoreanError = 'Failed to load Action Korean: $e';
      print('Error loading Action Korean: $e');
    } finally {
      _isLoadingActionKorean = false;
      notifyListeners();
    }
  }

  // Load thriller Korean
  Future<void> loadThrillerKorean() async {
    _isLoadingThrillerKorean = true;
    _thrillerKoreanError = null;
    notifyListeners();

    try {
      // Thriller Korean movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'with_genres': '53',
        'vote_count.gte': '25',
        'page': '1',
      });
      _thrillerKorean = results;
      _thrillerKoreanError = null;
    } catch (e) {
      _thrillerKoreanError = 'Failed to load Thriller Korean: $e';
      print('Error loading Thriller Korean: $e');
    } finally {
      _isLoadingThrillerKorean = false;
      notifyListeners();
    }
  }

  // Load popular Korean TV
  Future<void> loadPopularKoreanTv() async {
    _isLoadingPopularKoreanTv = true;
    _popularKoreanTvError = null;
    notifyListeners();

    try {
      // Popular Korean TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'ko',
        'region': 'KR',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _popularKoreanTv = results;
      _popularKoreanTvError = null;
    } catch (e) {
      _popularKoreanTvError = 'Failed to load Popular Korean TV: $e';
      print('Error loading Popular Korean TV: $e');
    } finally {
      _isLoadingPopularKoreanTv = false;
      notifyListeners();
    }
  }

  // Load Top Rated Korean TV
  Future<void> loadTopRatedKoreanTv() async {
    _isLoadingTopRatedKoreanTv = true;
    _topRatedKoreanTvError = null;
    notifyListeners();

    try {
      // Top-rated Korean TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'ko',
        'region': 'KR',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '20',
        'page': '1',
      });
      _topRatedKoreanTv = results;
      _topRatedKoreanTvError = null;
    } catch (e) {
      _topRatedKoreanTvError = 'Failed to load Top Rated Korean TV: $e';
      print('Error loading Top Rated Korean TV: $e');
    } finally {
      _isLoadingTopRatedKoreanTv = false;
      notifyListeners();
    }
  }

  // Load new releases Korean
  Future<void> loadNewReleasesKorean() async {
    _isLoadingNewReleasesKorean = true;
    _newReleasesKoreanError = null;
    notifyListeners();

    try {
      // New Korean releases 2024-2025
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'primary_release_date.gte': '2024-01-01',
        'sort_by': 'primary_release_date.desc',
        'vote_count.gte': '10',
        'page': '1',
      });
      _newReleasesKorean = results;
      _newReleasesKoreanError = null;
    } catch (e) {
      _newReleasesKoreanError = 'Failed to load new releases Korean: $e';
      print('Error loading new releases Korean: $e');
    } finally {
      _isLoadingNewReleasesKorean = false;
      notifyListeners();
    }
  }

  // Load blockbuster hits Korean
  Future<void> loadBlockbusterHitsKorean() async {
    _isLoadingBlockbusterHitsKorean = true;
    _blockbusterHitsKoreanError = null;
    notifyListeners();

    try {
      // Korean blockbuster hits by revenue
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'sort_by': 'revenue.desc',
        'vote_count.gte': '100',
        'page': '1',
      });
      _blockbusterHitsKorean = results;
      _blockbusterHitsKoreanError = null;
    } catch (e) {
      _blockbusterHitsKoreanError =
          'Failed to load blockbuster hits Korean: $e';
      print('Error loading blockbuster hits Korean: $e');
    } finally {
      _isLoadingBlockbusterHitsKorean = false;
      notifyListeners();
    }
  }

  // Load critically acclaimed Korean
  Future<void> loadCriticallyAcclaimedKorean() async {
    _isLoadingCriticallyAcclaimedKorean = true;
    _criticallyAcclaimedKoreanError = null;
    notifyListeners();

    try {
      // Critically acclaimed Korean movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'vote_average.gte': '7.5',
        'vote_count.gte': '50',
        'sort_by': 'vote_average.desc',
        'page': '1',
      });
      _criticallyAcclaimedKorean = results;
      _criticallyAcclaimedKoreanError = null;
    } catch (e) {
      _criticallyAcclaimedKoreanError =
          'Failed to load critically acclaimed Korean: $e';
      print('Error loading critically acclaimed Korean: $e');
    } finally {
      _isLoadingCriticallyAcclaimedKorean = false;
      notifyListeners();
    }
  }

  // Load family entertainment Korean
  Future<void> loadFamilyEntertainmentKorean() async {
    _isLoadingFamilyEntertainmentKorean = true;
    _familyEntertainmentKoreanError = null;
    notifyListeners();

    try {
      // Korean family entertainment
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'with_genres': '16,10751',
        'vote_count.gte': '25',
        'page': '1',
      });
      _familyEntertainmentKorean = results;
      _familyEntertainmentKoreanError = null;
    } catch (e) {
      _familyEntertainmentKoreanError =
          'Failed to load family entertainment Korean: $e';
      print('Error loading family entertainment Korean: $e');
    } finally {
      _isLoadingFamilyEntertainmentKorean = false;
      notifyListeners();
    }
  }

  // Load comedy gold Korean
  Future<void> loadComedyGoldKorean() async {
    _isLoadingComedyGoldKorean = true;
    _comedyGoldKoreanError = null;
    notifyListeners();

    try {
      // Korean comedy movies
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'with_genres': '35',
        'vote_count.gte': '25',
        'page': '1',
      });
      _comedyGoldKorean = results;
      _comedyGoldKoreanError = null;
    } catch (e) {
      _comedyGoldKoreanError = 'Failed to load comedy gold Korean: $e';
      print('Error loading comedy gold Korean: $e');
    } finally {
      _isLoadingComedyGoldKorean = false;
      notifyListeners();
    }
  }

  // Load romantic dramas Korean
  Future<void> loadRomanticDramasKorean() async {
    _isLoadingRomanticDramasKorean = true;
    _romanticDramasKoreanError = null;
    notifyListeners();

    try {
      // Korean romantic dramas
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'with_genres': '18,10749',
        'vote_count.gte': '25',
        'page': '1',
      });
      _romanticDramasKorean = results;
      _romanticDramasKoreanError = null;
    } catch (e) {
      _romanticDramasKoreanError = 'Failed to load romantic dramas Korean: $e';
      print('Error loading romantic dramas Korean: $e');
    } finally {
      _isLoadingRomanticDramasKorean = false;
      notifyListeners();
    }
  }

  // Load mystery crime Korean
  Future<void> loadMysteryCrimeKorean() async {
    _isLoadingMysteryCrimeKorean = true;
    _mysteryCrimeKoreanError = null;
    notifyListeners();

    try {
      // Korean mystery and crime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'with_genres': '80,9648',
        'vote_count.gte': '25',
        'page': '1',
      });
      _mysteryCrimeKorean = results;
      _mysteryCrimeKoreanError = null;
    } catch (e) {
      _mysteryCrimeKoreanError = 'Failed to load mystery crime Korean: $e';
      print('Error loading mystery crime Korean: $e');
    } finally {
      _isLoadingMysteryCrimeKorean = false;
      notifyListeners();
    }
  }

  // Load biographical Korean
  Future<void> loadBiographicalKorean() async {
    _isLoadingBiographicalKorean = true;
    _biographicalKoreanError = null;
    notifyListeners();

    try {
      // Korean biographical films
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'with_genres': '36',
        'vote_count.gte': '25',
        'page': '1',
      });
      _biographicalKorean = results;
      _biographicalKoreanError = null;
    } catch (e) {
      _biographicalKoreanError = 'Failed to load biographical Korean: $e';
      print('Error loading biographical Korean: $e');
    } finally {
      _isLoadingBiographicalKorean = false;
      notifyListeners();
    }
  }

  // Load web series Korean
  Future<void> loadWebSeriesKorean() async {
    _isLoadingWebSeriesKorean = true;
    _webSeriesKoreanError = null;
    notifyListeners();

    try {
      // Korean web series and TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'ko',
        'region': 'KR',
        'sort_by': 'popularity.desc',
        'vote_count.gte': '20',
        'page': '1',
      });
      _webSeriesKorean = results;
      _webSeriesKoreanError = null;
    } catch (e) {
      _webSeriesKoreanError = 'Failed to load web series Korean: $e';
      print('Error loading web series Korean: $e');
    } finally {
      _isLoadingWebSeriesKorean = false;
      notifyListeners();
    }
  }

  // Load upcoming Korean
  Future<void> loadUpcomingKorean() async {
    _isLoadingUpcomingKorean = true;
    _upcomingKoreanError = null;
    notifyListeners();

    try {
      // Upcoming Korean releases
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'primary_release_date.gte': '2024-01-01',
        'sort_by': 'primary_release_date.asc',
        'vote_count.gte': '5',
        'page': '1',
      });
      _upcomingKorean = results;
      _upcomingKoreanError = null;
    } catch (e) {
      _upcomingKoreanError = 'Failed to load upcoming Korean: $e';
      print('Error loading upcoming Korean: $e');
    } finally {
      _isLoadingUpcomingKorean = false;
      notifyListeners();
    }
  }

  // Load award winners Korean
  Future<void> loadAwardWinnersKorean() async {
    _isLoadingAwardWinnersKorean = true;
    _awardWinnersKoreanError = null;
    notifyListeners();

    try {
      // Korean award-winning films
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'vote_average.gte': '8.0',
        'vote_count.gte': '100',
        'sort_by': 'vote_average.desc',
        'page': '1',
      });
      _awardWinnersKorean = results;
      _awardWinnersKoreanError = null;
    } catch (e) {
      _awardWinnersKoreanError = 'Failed to load award winners Korean: $e';
      print('Error loading award winners Korean: $e');
    } finally {
      _isLoadingAwardWinnersKorean = false;
      notifyListeners();
    }
  }

  // Load Korean classics
  Future<void> loadKoreanClassics() async {
    _isLoadingKoreanClassics = true;
    _koreanClassicsError = null;
    notifyListeners();

    try {
      // Korean classic films
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'primary_release_date.lte': '2010-12-31',
        'vote_average.gte': '7.0',
        'vote_count.gte': '50',
        'sort_by': 'vote_average.desc',
        'page': '1',
      });
      _koreanClassics = results;
      _koreanClassicsError = null;
    } catch (e) {
      _koreanClassicsError = 'Failed to load Korean classics: $e';
      print('Error loading Korean classics: $e');
    } finally {
      _isLoadingKoreanClassics = false;
      notifyListeners();
    }
  }

  // Load Top Rated Netflix
  Future<void> loadTopRatedNetflix() async {
    _isLoadingTopRatedNetflix = true;
    _topRatedNetflixError = null;
    notifyListeners();

    try {
      // Top-rated Netflix content (Indian - Hindi prioritized)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi,ta,te,ml,bn,gu,kn,mr,pa,en',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '100',
        'page': '1',
        'with_origin_country': 'IN',
      });
      _topRatedNetflix = results;
      _topRatedNetflixError = null;
    } catch (e) {
      _topRatedNetflixError = 'Failed to load Top Rated Netflix: $e';
      print('Error loading Top Rated Netflix: $e');
    } finally {
      _isLoadingTopRatedNetflix = false;
      notifyListeners();
    }
  }

  // Load Action Netflix
  Future<void> loadActionNetflix() async {
    _isLoadingActionNetflix = true;
    _actionNetflixError = null;
    notifyListeners();

    try {
      // Action Netflix content (Indian - Hindi prioritized)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi,ta,te,ml,bn,gu,kn,mr,pa,en',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '28',
        'vote_count.gte': '50',
        'page': '1',
        'with_origin_country': 'IN',
      });
      _actionNetflix = results;
      _actionNetflixError = null;
    } catch (e) {
      _actionNetflixError = 'Failed to load Action Netflix: $e';
      print('Error loading Action Netflix: $e');
    } finally {
      _isLoadingActionNetflix = false;
      notifyListeners();
    }
  }

  // Load Comedy Netflix
  Future<void> loadComedyNetflix() async {
    _isLoadingComedyNetflix = true;
    _comedyNetflixError = null;
    notifyListeners();

    try {
      // Comedy Netflix content (Indian - Hindi prioritized)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi,ta,te,ml,bn,gu,kn,mr,pa,en',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '35',
        'vote_count.gte': '50',
        'page': '1',
        'with_origin_country': 'IN',
      });
      _comedyNetflix = results;
      _comedyNetflixError = null;
    } catch (e) {
      _comedyNetflixError = 'Failed to load Comedy Netflix: $e';
      print('Error loading Comedy Netflix: $e');
    } finally {
      _isLoadingComedyNetflix = false;
      notifyListeners();
    }
  }

  // Load Drama Netflix
  Future<void> loadDramaNetflix() async {
    _isLoadingDramaNetflix = true;
    _dramaNetflixError = null;
    notifyListeners();

    try {
      // Drama Netflix content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '18',
        'page': '1',
      });
      _dramaNetflix = results;
      _dramaNetflixError = null;
    } catch (e) {
      _dramaNetflixError = 'Failed to load Drama Netflix: $e';
      print('Error loading Drama Netflix: $e');
    } finally {
      _isLoadingDramaNetflix = false;
      notifyListeners();
    }
  }

  // Load Thriller Netflix
  Future<void> loadThrillerNetflix() async {
    _isLoadingThrillerNetflix = true;
    _thrillerNetflixError = null;
    notifyListeners();

    try {
      // Thriller Netflix content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '53',
        'page': '1',
      });
      _thrillerNetflix = results;
      _thrillerNetflixError = null;
    } catch (e) {
      _thrillerNetflixError = 'Failed to load Thriller Netflix: $e';
      print('Error loading Thriller Netflix: $e');
    } finally {
      _isLoadingThrillerNetflix = false;
      notifyListeners();
    }
  }

  // Load Horror Netflix
  Future<void> loadHorrorNetflix() async {
    _isLoadingHorrorNetflix = true;
    _horrorNetflixError = null;
    notifyListeners();

    try {
      // Horror Netflix content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '27',
        'page': '1',
      });
      _horrorNetflix = results;
      _horrorNetflixError = null;
    } catch (e) {
      _horrorNetflixError = 'Failed to load Horror Netflix: $e';
      print('Error loading Horror Netflix: $e');
    } finally {
      _isLoadingHorrorNetflix = false;
      notifyListeners();
    }
  }

  // Load Sci-Fi Netflix
  Future<void> loadScifiNetflix() async {
    _isLoadingScifiNetflix = true;
    _scifiNetflixError = null;
    notifyListeners();

    try {
      // Sci-Fi Netflix content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '878,14',
        'page': '1',
      });
      _scifiNetflix = results;
      _scifiNetflixError = null;
    } catch (e) {
      _scifiNetflixError = 'Failed to load Sci-Fi Netflix: $e';
      print('Error loading Sci-Fi Netflix: $e');
    } finally {
      _isLoadingScifiNetflix = false;
      notifyListeners();
    }
  }

  // Load featured Korean
  Future<void> loadFeaturedKorean() async {
    _isLoadingFeaturedKorean = true;
    _featuredKoreanError = null;
    notifyListeners();

    try {
      // Featured Korean movies and TV shows
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'ko',
        'region': 'KR',
        'sort_by': 'popularity.desc',
        'vote_count.gte': '100',
        'page': '1',
      });
      _featuredKorean = results;
      _featuredKoreanError = null;
    } catch (e) {
      _featuredKoreanError = 'Failed to load featured Korean: $e';
      print('Error loading featured Korean: $e');
    } finally {
      _isLoadingFeaturedKorean = false;
      notifyListeners();
    }
  }

  // Load New Releases Netflix
  Future<void> loadNewReleasesNetflix() async {
    _isLoadingNewReleasesNetflix = true;
    _newReleasesNetflixError = null;
    notifyListeners();

    try {
      // New releases on Netflix (last 6 months)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'primary_release_date.gte': '2024-01-01',
        'sort_by': 'primary_release_date.desc',
        'page': '1',
      });
      _newReleasesNetflix = results;
      _newReleasesNetflixError = null;
    } catch (e) {
      _newReleasesNetflixError = 'Failed to load New Releases Netflix: $e';
      print('Error loading New Releases Netflix: $e');
    } finally {
      _isLoadingNewReleasesNetflix = false;
      notifyListeners();
    }
  }

  // Load Popular Netflix
  Future<void> loadPopularNetflix() async {
    _isLoadingPopularNetflix = true;
    _popularNetflixError = null;
    notifyListeners();

    try {
      // Popular content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'sort_by': 'popularity.desc',
        'vote_count.gte': '200',
        'page': '1',
      });
      _popularNetflix = results;
      _popularNetflixError = null;
    } catch (e) {
      _popularNetflixError = 'Failed to load Popular Netflix: $e';
      print('Error loading Popular Netflix: $e');
    } finally {
      _isLoadingPopularNetflix = false;
      notifyListeners();
    }
  }

  // Load Award Winners Netflix
  Future<void> loadAwardWinnersNetflix() async {
    _isLoadingAwardWinnersNetflix = true;
    _awardWinnersNetflixError = null;
    notifyListeners();

    try {
      // Award-winning content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '500',
        'vote_average.gte': '7.5',
        'page': '1',
      });
      _awardWinnersNetflix = results;
      _awardWinnersNetflixError = null;
    } catch (e) {
      _awardWinnersNetflixError = 'Failed to load Award Winners Netflix: $e';
      print('Error loading Award Winners Netflix: $e');
    } finally {
      _isLoadingAwardWinnersNetflix = false;
      notifyListeners();
    }
  }

  // Load Family Content Netflix
  Future<void> loadFamilyContentNetflix() async {
    _isLoadingFamilyContentNetflix = true;
    _familyContentNetflixError = null;
    notifyListeners();

    try {
      // Family-friendly content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '16,10751', // Animation, Family
        'certification_country': 'US',
        'certification.lte': 'PG-13',
        'page': '1',
      });
      _familyContentNetflix = results;
      _familyContentNetflixError = null;
    } catch (e) {
      _familyContentNetflixError = 'Failed to load Family Content Netflix: $e';
      print('Error loading Family Content Netflix: $e');
    } finally {
      _isLoadingFamilyContentNetflix = false;
      notifyListeners();
    }
  }

  // Load Romance Netflix
  Future<void> loadRomanceNetflix() async {
    _isLoadingRomanceNetflix = true;
    _romanceNetflixError = null;
    notifyListeners();

    try {
      // Romance content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '10749', // Romance
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _romanceNetflix = results;
      _romanceNetflixError = null;
    } catch (e) {
      _romanceNetflixError = 'Failed to load Romance Netflix: $e';
      print('Error loading Romance Netflix: $e');
    } finally {
      _isLoadingRomanceNetflix = false;
      notifyListeners();
    }
  }

  // Load Mystery Netflix
  Future<void> loadMysteryNetflix() async {
    _isLoadingMysteryNetflix = true;
    _mysteryNetflixError = null;
    notifyListeners();

    try {
      // Mystery content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '9648', // Mystery
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _mysteryNetflix = results;
      _mysteryNetflixError = null;
    } catch (e) {
      _mysteryNetflixError = 'Failed to load Mystery Netflix: $e';
      print('Error loading Mystery Netflix: $e');
    } finally {
      _isLoadingMysteryNetflix = false;
      notifyListeners();
    }
  }

  // Load Crime Netflix
  Future<void> loadCrimeNetflix() async {
    _isLoadingCrimeNetflix = true;
    _crimeNetflixError = null;
    notifyListeners();

    try {
      // Crime content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '80', // Crime
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _crimeNetflix = results;
      _crimeNetflixError = null;
    } catch (e) {
      _crimeNetflixError = 'Failed to load Crime Netflix: $e';
      print('Error loading Crime Netflix: $e');
    } finally {
      _isLoadingCrimeNetflix = false;
      notifyListeners();
    }
  }

  // Load Animation Netflix
  Future<void> loadAnimationNetflix() async {
    _isLoadingAnimationNetflix = true;
    _animationNetflixError = null;
    notifyListeners();

    try {
      // Animation content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '16', // Animation
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _animationNetflix = results;
      _animationNetflixError = null;
    } catch (e) {
      _animationNetflixError = 'Failed to load Animation Netflix: $e';
      print('Error loading Animation Netflix: $e');
    } finally {
      _isLoadingAnimationNetflix = false;
      notifyListeners();
    }
  }

  // Load Documentary Netflix
  Future<void> loadDocumentaryNetflix() async {
    _isLoadingDocumentaryNetflix = true;
    _documentaryNetflixError = null;
    notifyListeners();

    try {
      // Documentary content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_genres': '99', // Documentary
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _documentaryNetflix = results;
      _documentaryNetflixError = null;
    } catch (e) {
      _documentaryNetflixError = 'Failed to load Documentary Netflix: $e';
      print('Error loading Documentary Netflix: $e');
    } finally {
      _isLoadingDocumentaryNetflix = false;
      notifyListeners();
    }
  }

  // Load International Netflix
  Future<void> loadInternationalNetflix() async {
    _isLoadingInternationalNetflix = true;
    _internationalNetflixError = null;
    notifyListeners();

    try {
      // International content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'with_original_language': '!en',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _internationalNetflix = results;
      _internationalNetflixError = null;
    } catch (e) {
      _internationalNetflixError = 'Failed to load International Netflix: $e';
      print('Error loading International Netflix: $e');
    } finally {
      _isLoadingInternationalNetflix = false;
      notifyListeners();
    }
  }

  // Load Classic Netflix
  Future<void> loadClassicNetflix() async {
    _isLoadingClassicNetflix = true;
    _classicNetflixError = null;
    notifyListeners();

    try {
      // Classic content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'primary_release_date.lte': '2000-12-31',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '1000',
        'page': '1',
      });
      _classicNetflix = results;
      _classicNetflixError = null;
    } catch (e) {
      _classicNetflixError = 'Failed to load Classic Netflix: $e';
      print('Error loading Classic Netflix: $e');
    } finally {
      _isLoadingClassicNetflix = false;
      notifyListeners();
    }
  }

  // Load Upcoming Netflix
  Future<void> loadUpcomingNetflix() async {
    _isLoadingUpcomingNetflix = true;
    _upcomingNetflixError = null;
    notifyListeners();

    try {
      // Upcoming content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'primary_release_date.gte': '2024-06-01',
        'sort_by': 'primary_release_date.asc',
        'page': '1',
      });
      _upcomingNetflix = results;
      _upcomingNetflixError = null;
    } catch (e) {
      _upcomingNetflixError = 'Failed to load Upcoming Netflix: $e';
      print('Error loading Upcoming Netflix: $e');
    } finally {
      _isLoadingUpcomingNetflix = false;
      notifyListeners();
    }
  }

  // Load Critically Acclaimed Netflix
  Future<void> loadCriticallyAcclaimedNetflix() async {
    _isLoadingCriticallyAcclaimedNetflix = true;
    _criticallyAcclaimedNetflixError = null;
    notifyListeners();

    try {
      // Critically acclaimed content on Netflix
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix provider ID
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '300',
        'vote_average.gte': '7.0',
        'page': '1',
      });
      _criticallyAcclaimedNetflix = results;
      _criticallyAcclaimedNetflixError = null;
    } catch (e) {
      _criticallyAcclaimedNetflixError =
          'Failed to load Critically Acclaimed Netflix: $e';
      print('Error loading Critically Acclaimed Netflix: $e');
    } finally {
      _isLoadingCriticallyAcclaimedNetflix = false;
      notifyListeners();
    }
  }

  // Load Top Rated Prime
  Future<void> loadTopRatedPrime() async {
    _isLoadingTopRatedPrime = true;
    _topRatedPrimeError = null;
    notifyListeners();

    try {
      // Top-rated Prime content (Indian - Hindi prioritized)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi,ta,te,ml,bn,gu,kn,mr,pa,en',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '300',
        'page': '1',
        'with_origin_country': 'IN',
      });
      _topRatedPrime = results;
      _topRatedPrimeError = null;
    } catch (e) {
      _topRatedPrimeError = 'Failed to load Top Rated Prime: $e';
      print('Error loading Top Rated Prime: $e');
    } finally {
      _isLoadingTopRatedPrime = false;
      notifyListeners();
    }
  }

  // Load Action Prime
  Future<void> loadActionPrime() async {
    _isLoadingActionPrime = true;
    _actionPrimeError = null;
    notifyListeners();

    try {
      // Action Prime content (Indian - Hindi prioritized)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi,ta,te,ml,bn,gu,kn,mr,pa,en',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'with_genres': '28',
        'page': '1',
        'with_origin_country': 'IN',
      });
      _actionPrime = results;
      _actionPrimeError = null;
    } catch (e) {
      _actionPrimeError = 'Failed to load Action Prime: $e';
      print('Error loading Action Prime: $e');
    } finally {
      _isLoadingActionPrime = false;
      notifyListeners();
    }
  }

  // Load Comedy Prime
  Future<void> loadComedyPrime() async {
    _isLoadingComedyPrime = true;
    _comedyPrimeError = null;
    notifyListeners();

    try {
      // Comedy Prime content (Indian - Hindi prioritized)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi,ta,te,ml,bn,gu,kn,mr,pa,en',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'with_genres': '35',
        'page': '1',
        'with_origin_country': 'IN',
      });
      _comedyPrime = results;
      _comedyPrimeError = null;
    } catch (e) {
      _comedyPrimeError = 'Failed to load Comedy Prime: $e';
      print('Error loading Comedy Prime: $e');
    } finally {
      _isLoadingComedyPrime = false;
      notifyListeners();
    }
  }

  // Load Drama Prime
  Future<void> loadDramaPrime() async {
    _isLoadingDramaPrime = true;
    _dramaPrimeError = null;
    notifyListeners();

    try {
      // Drama Prime content (Indian - Hindi prioritized)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_original_language': 'hi,ta,te,ml,bn,gu,kn,mr,pa,en',
        'region': 'IN',
        'watch_region': 'IN',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'with_genres': '18',
        'page': '1',
        'with_origin_country': 'IN',
      });
      _dramaPrime = results;
      _dramaPrimeError = null;
    } catch (e) {
      _dramaPrimeError = 'Failed to load Drama Prime: $e';
      print('Error loading Drama Prime: $e');
    } finally {
      _isLoadingDramaPrime = false;
      notifyListeners();
    }
  }

  // Load Thriller Prime
  Future<void> loadThrillerPrime() async {
    _isLoadingThrillerPrime = true;
    _thrillerPrimeError = null;
    notifyListeners();

    try {
      // Thriller Prime content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'with_genres': '53',
        'page': '1',
      });
      _thrillerPrime = results;
      _thrillerPrimeError = null;
    } catch (e) {
      _thrillerPrimeError = 'Failed to load Thriller Prime: $e';
      print('Error loading Thriller Prime: $e');
    } finally {
      _isLoadingThrillerPrime = false;
      notifyListeners();
    }
  }

  // Load Sci-Fi Prime
  Future<void> loadScifiPrime() async {
    _isLoadingScifiPrime = true;
    _scifiPrimeError = null;
    notifyListeners();

    try {
      // Sci-Fi Prime content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'with_genres': '878,14',
        'page': '1',
      });
      _scifiPrime = results;
      _scifiPrimeError = null;
    } catch (e) {
      _scifiPrimeError = 'Failed to load Sci-Fi Prime: $e';
      print('Error loading Sci-Fi Prime: $e');
    } finally {
      _isLoadingScifiPrime = false;
      notifyListeners();
    }
  }

  // Load Romance Prime
  Future<void> loadRomancePrime() async {
    _isLoadingRomancePrime = true;
    _romancePrimeError = null;
    notifyListeners();

    try {
      // Romance Prime content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '119', // Prime provider ID
        'with_genres': '10749',
        'page': '1',
      });
      _romancePrime = results;
      _romancePrimeError = null;
    } catch (e) {
      _romancePrimeError = 'Failed to load Romance Prime: $e';
      print('Error loading Romance Prime: $e');
    } finally {
      _isLoadingRomancePrime = false;
      notifyListeners();
    }
  }

  // Load Popular TV Prime
  Future<void> loadPopularTvPrime() async {
    _isLoadingPopularTvPrime = true;
    _popularTvPrimeError = null;
    notifyListeners();

    try {
      // Popular Prime TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en', // Assuming English for TV shows
        'region': 'US',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _popularTvPrime = results;
      _popularTvPrimeError = null;
    } catch (e) {
      _popularTvPrimeError = 'Failed to load Popular TV Prime: $e';
      print('Error loading Popular TV Prime: $e');
    } finally {
      _isLoadingPopularTvPrime = false;
      notifyListeners();
    }
  }

  // Load Comedy TV Prime
  Future<void> loadComedyTvPrime() async {
    _isLoadingComedyTvPrime = true;
    _comedyTvPrimeError = null;
    notifyListeners();

    try {
      // Comedy Prime TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en', // Assuming English for TV shows
        'region': 'US',
        'with_genres': '35',
        'page': '1',
      });
      _comedyTvPrime = results;
      _comedyTvPrimeError = null;
    } catch (e) {
      _comedyTvPrimeError = 'Failed to load Comedy TV Prime: $e';
      print('Error loading Comedy TV Prime: $e');
    } finally {
      _isLoadingComedyTvPrime = false;
      notifyListeners();
    }
  }

  // Load Drama TV Prime
  Future<void> loadDramaTvPrime() async {
    _isLoadingDramaTvPrime = true;
    _dramaTvPrimeError = null;
    notifyListeners();

    try {
      // Drama Prime TV shows
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en', // Assuming English for TV shows
        'region': 'US',
        'with_genres': '18',
        'page': '1',
      });
      _dramaTvPrime = results;
      _dramaTvPrimeError = null;
    } catch (e) {
      _dramaTvPrimeError = 'Failed to load Drama TV Prime: $e';
      print('Error loading Drama TV Prime: $e');
    } finally {
      _isLoadingDramaTvPrime = false;
      notifyListeners();
    }
  }

  // Load New Releases Prime
  Future<void> loadNewReleasesPrime() async {
    _isLoadingNewReleasesPrime = true;
    _newReleasesPrimeError = null;
    notifyListeners();

    try {
      // New releases on Prime (last 6 months)
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'primary_release_date.gte': '2024-01-01',
        'sort_by': 'primary_release_date.desc',
        'page': '1',
      });
      _newReleasesPrime = results;
      _newReleasesPrimeError = null;
    } catch (e) {
      _newReleasesPrimeError = 'Failed to load New Releases Prime: $e';
      print('Error loading New Releases Prime: $e');
    } finally {
      _isLoadingNewReleasesPrime = false;
      notifyListeners();
    }
  }

  // Load Popular Prime
  Future<void> loadPopularPrime() async {
    _isLoadingPopularPrime = true;
    _popularPrimeError = null;
    notifyListeners();

    try {
      // Popular content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'sort_by': 'popularity.desc',
        'vote_count.gte': '200',
        'page': '1',
      });
      _popularPrime = results;
      _popularPrimeError = null;
    } catch (e) {
      _popularPrimeError = 'Failed to load Popular Prime: $e';
      print('Error loading Popular Prime: $e');
    } finally {
      _isLoadingPopularPrime = false;
      notifyListeners();
    }
  }

  // Load Award Winners Prime
  Future<void> loadAwardWinnersPrime() async {
    _isLoadingAwardWinnersPrime = true;
    _awardWinnersPrimeError = null;
    notifyListeners();

    try {
      // Award-winning content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '500',
        'vote_average.gte': '7.5',
        'page': '1',
      });
      _awardWinnersPrime = results;
      _awardWinnersPrimeError = null;
    } catch (e) {
      _awardWinnersPrimeError = 'Failed to load Award Winners Prime: $e';
      print('Error loading Award Winners Prime: $e');
    } finally {
      _isLoadingAwardWinnersPrime = false;
      notifyListeners();
    }
  }

  // Load Family Content Prime
  Future<void> loadFamilyContentPrime() async {
    _isLoadingFamilyContentPrime = true;
    _familyContentPrimeError = null;
    notifyListeners();

    try {
      // Family-friendly content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '16,10751', // Animation, Family
        'certification_country': 'US',
        'certification.lte': 'PG-13',
        'page': '1',
      });
      _familyContentPrime = results;
      _familyContentPrimeError = null;
    } catch (e) {
      _familyContentPrimeError = 'Failed to load Family Content Prime: $e';
      print('Error loading Family Content Prime: $e');
    } finally {
      _isLoadingFamilyContentPrime = false;
      notifyListeners();
    }
  }

  // Load Mystery Prime
  Future<void> loadMysteryPrime() async {
    _isLoadingMysteryPrime = true;
    _mysteryPrimeError = null;
    notifyListeners();

    try {
      // Mystery content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '9648', // Mystery
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _mysteryPrime = results;
      _mysteryPrimeError = null;
    } catch (e) {
      _mysteryPrimeError = 'Failed to load Mystery Prime: $e';
      print('Error loading Mystery Prime: $e');
    } finally {
      _isLoadingMysteryPrime = false;
      notifyListeners();
    }
  }

  // Load Crime Prime
  Future<void> loadCrimePrime() async {
    _isLoadingCrimePrime = true;
    _crimePrimeError = null;
    notifyListeners();

    try {
      // Crime content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '80', // Crime
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _crimePrime = results;
      _crimePrimeError = null;
    } catch (e) {
      _crimePrimeError = 'Failed to load Crime Prime: $e';
      print('Error loading Crime Prime: $e');
    } finally {
      _isLoadingCrimePrime = false;
      notifyListeners();
    }
  }

  // Load Animation Prime
  Future<void> loadAnimationPrime() async {
    _isLoadingAnimationPrime = true;
    _animationPrimeError = null;
    notifyListeners();

    try {
      // Animation content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '16', // Animation
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _animationPrime = results;
      _animationPrimeError = null;
    } catch (e) {
      _animationPrimeError = 'Failed to load Animation Prime: $e';
      print('Error loading Animation Prime: $e');
    } finally {
      _isLoadingAnimationPrime = false;
      notifyListeners();
    }
  }

  // Load Documentary Prime
  Future<void> loadDocumentaryPrime() async {
    _isLoadingDocumentaryPrime = true;
    _documentaryPrimeError = null;
    notifyListeners();

    try {
      // Documentary content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '99', // Documentary
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _documentaryPrime = results;
      _documentaryPrimeError = null;
    } catch (e) {
      _documentaryPrimeError = 'Failed to load Documentary Prime: $e';
      print('Error loading Documentary Prime: $e');
    } finally {
      _isLoadingDocumentaryPrime = false;
      notifyListeners();
    }
  }

  // Load International Prime
  Future<void> loadInternationalPrime() async {
    _isLoadingInternationalPrime = true;
    _internationalPrimeError = null;
    notifyListeners();

    try {
      // International content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_original_language': '!en',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _internationalPrime = results;
      _internationalPrimeError = null;
    } catch (e) {
      _internationalPrimeError = 'Failed to load International Prime: $e';
      print('Error loading International Prime: $e');
    } finally {
      _isLoadingInternationalPrime = false;
      notifyListeners();
    }
  }

  // Load Classic Prime
  Future<void> loadClassicPrime() async {
    _isLoadingClassicPrime = true;
    _classicPrimeError = null;
    notifyListeners();

    try {
      // Classic content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'primary_release_date.lte': '2000-12-31',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '1000',
        'page': '1',
      });
      _classicPrime = results;
      _classicPrimeError = null;
    } catch (e) {
      _classicPrimeError = 'Failed to load Classic Prime: $e';
      print('Error loading Classic Prime: $e');
    } finally {
      _isLoadingClassicPrime = false;
      notifyListeners();
    }
  }

  // Load Upcoming Prime
  Future<void> loadUpcomingPrime() async {
    _isLoadingUpcomingPrime = true;
    _upcomingPrimeError = null;
    notifyListeners();

    try {
      // Upcoming content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'primary_release_date.gte': '2024-06-01',
        'sort_by': 'primary_release_date.asc',
        'page': '1',
      });
      _upcomingPrime = results;
      _upcomingPrimeError = null;
    } catch (e) {
      _upcomingPrimeError = 'Failed to load Upcoming Prime: $e';
      print('Error loading Upcoming Prime: $e');
    } finally {
      _isLoadingUpcomingPrime = false;
      notifyListeners();
    }
  }

  // Load Critically Acclaimed Prime
  Future<void> loadCriticallyAcclaimedPrime() async {
    _isLoadingCriticallyAcclaimedPrime = true;
    _criticallyAcclaimedPrimeError = null;
    notifyListeners();

    try {
      // Critically acclaimed content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '300',
        'vote_average.gte': '7.0',
        'page': '1',
      });
      _criticallyAcclaimedPrime = results;
      _criticallyAcclaimedPrimeError = null;
    } catch (e) {
      _criticallyAcclaimedPrimeError =
          'Failed to load Critically Acclaimed Prime: $e';
      print('Error loading Critically Acclaimed Prime: $e');
    } finally {
      _isLoadingCriticallyAcclaimedPrime = false;
      notifyListeners();
    }
  }

  // Load Horror Prime
  Future<void> loadHorrorPrime() async {
    _isLoadingHorrorPrime = true;
    _horrorPrimeError = null;
    notifyListeners();

    try {
      // Horror content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '27', // Horror
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _horrorPrime = results;
      _horrorPrimeError = null;
    } catch (e) {
      _horrorPrimeError = 'Failed to load Horror Prime: $e';
      print('Error loading Horror Prime: $e');
    } finally {
      _isLoadingHorrorPrime = false;
      notifyListeners();
    }
  }

  // Load War Prime
  Future<void> loadWarPrime() async {
    _isLoadingWarPrime = true;
    _warPrimeError = null;
    notifyListeners();

    try {
      // War content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '10752', // War
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _warPrime = results;
      _warPrimeError = null;
    } catch (e) {
      _warPrimeError = 'Failed to load War Prime: $e';
      print('Error loading War Prime: $e');
    } finally {
      _isLoadingWarPrime = false;
      notifyListeners();
    }
  }

  // Load Western Prime
  Future<void> loadWesternPrime() async {
    _isLoadingWesternPrime = true;
    _westernPrimeError = null;
    notifyListeners();

    try {
      // Western content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '37', // Western
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _westernPrime = results;
      _westernPrimeError = null;
    } catch (e) {
      _westernPrimeError = 'Failed to load Western Prime: $e';
      print('Error loading Western Prime: $e');
    } finally {
      _isLoadingWesternPrime = false;
      notifyListeners();
    }
  }

  // Load Musical Prime
  Future<void> loadMusicalPrime() async {
    _isLoadingMusicalPrime = true;
    _musicalPrimeError = null;
    notifyListeners();

    try {
      // Musical content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '10402', // Musical
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _musicalPrime = results;
      _musicalPrimeError = null;
    } catch (e) {
      _musicalPrimeError = 'Failed to load Musical Prime: $e';
      print('Error loading Musical Prime: $e');
    } finally {
      _isLoadingMusicalPrime = false;
      notifyListeners();
    }
  }

  // Load Biographical Prime
  Future<void> loadBiographicalPrime() async {
    _isLoadingBiographicalPrime = true;
    _biographicalPrimeError = null;
    notifyListeners();

    try {
      // Biographical content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '36', // History
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _biographicalPrime = results;
      _biographicalPrimeError = null;
    } catch (e) {
      _biographicalPrimeError = 'Failed to load Biographical Prime: $e';
      print('Error loading Biographical Prime: $e');
    } finally {
      _isLoadingBiographicalPrime = false;
      notifyListeners();
    }
  }

  // Load Sports Prime
  Future<void> loadSportsPrime() async {
    _isLoadingSportsPrime = true;
    _sportsPrimeError = null;
    notifyListeners();

    try {
      // Sports content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '99', // Documentary (sports docs)
        'with_keywords': '180', // Sports
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _sportsPrime = results;
      _sportsPrimeError = null;
    } catch (e) {
      _sportsPrimeError = 'Failed to load Sports Prime: $e';
      print('Error loading Sports Prime: $e');
    } finally {
      _isLoadingSportsPrime = false;
      notifyListeners();
    }
  }

  // Load Adventure Prime
  Future<void> loadAdventurePrime() async {
    _isLoadingAdventurePrime = true;
    _adventurePrimeError = null;
    notifyListeners();

    try {
      // Adventure content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '12', // Adventure
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _adventurePrime = results;
      _adventurePrimeError = null;
    } catch (e) {
      _adventurePrimeError = 'Failed to load Adventure Prime: $e';
      print('Error loading Adventure Prime: $e');
    } finally {
      _isLoadingAdventurePrime = false;
      notifyListeners();
    }
  }

  // Load Fantasy Prime
  Future<void> loadFantasyPrime() async {
    _isLoadingFantasyPrime = true;
    _fantasyPrimeError = null;
    notifyListeners();

    try {
      // Fantasy content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '14', // Fantasy
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _fantasyPrime = results;
      _fantasyPrimeError = null;
    } catch (e) {
      _fantasyPrimeError = 'Failed to load Fantasy Prime: $e';
      print('Error loading Fantasy Prime: $e');
    } finally {
      _isLoadingFantasyPrime = false;
      notifyListeners();
    }
  }

  // Load Superhero Prime
  Future<void> loadSuperheroPrime() async {
    _isLoadingSuperheroPrime = true;
    _superheroPrimeError = null;
    notifyListeners();

    try {
      // Superhero content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_keywords': '180', // Superhero
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _superheroPrime = results;
      _superheroPrimeError = null;
    } catch (e) {
      _superheroPrimeError = 'Failed to load Superhero Prime: $e';
      print('Error loading Superhero Prime: $e');
    } finally {
      _isLoadingSuperheroPrime = false;
      notifyListeners();
    }
  }

  // Load Indie Prime
  Future<void> loadIndiePrime() async {
    _isLoadingIndiePrime = true;
    _indiePrimeError = null;
    notifyListeners();

    try {
      // Indie content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '18', // Drama (indie films)
        'vote_count.gte': '50',
        'vote_count.lte': '500',
        'sort_by': 'vote_average.desc',
        'page': '1',
      });
      _indiePrime = results;
      _indiePrimeError = null;
    } catch (e) {
      _indiePrimeError = 'Failed to load Indie Prime: $e';
      print('Error loading Indie Prime: $e');
    } finally {
      _isLoadingIndiePrime = false;
      notifyListeners();
    }
  }

  // Load Foreign Prime
  Future<void> loadForeignPrime() async {
    _isLoadingForeignPrime = true;
    _foreignPrimeError = null;
    notifyListeners();

    try {
      // Foreign content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_original_language': '!en',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _foreignPrime = results;
      _foreignPrimeError = null;
    } catch (e) {
      _foreignPrimeError = 'Failed to load Foreign Prime: $e';
      print('Error loading Foreign Prime: $e');
    } finally {
      _isLoadingForeignPrime = false;
      notifyListeners();
    }
  }

  // Load Teen Prime
  Future<void> loadTeenPrime() async {
    _isLoadingTeenPrime = true;
    _teenPrimeError = null;
    notifyListeners();

    try {
      // Teen content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '10749,35', // Romance, Comedy (teen-friendly)
        'certification_country': 'US',
        'certification.lte': 'PG-13',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _teenPrime = results;
      _teenPrimeError = null;
    } catch (e) {
      _teenPrimeError = 'Failed to load Teen Prime: $e';
      print('Error loading Teen Prime: $e');
    } finally {
      _isLoadingTeenPrime = false;
      notifyListeners();
    }
  }

  // Load Kids Prime
  Future<void> loadKidsPrime() async {
    _isLoadingKidsPrime = true;
    _kidsPrimeError = null;
    notifyListeners();

    try {
      // Kids content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '16,10751', // Animation, Family
        'certification_country': 'US',
        'certification.lte': 'G',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _kidsPrime = results;
      _kidsPrimeError = null;
    } catch (e) {
      _kidsPrimeError = 'Failed to load Kids Prime: $e';
      print('Error loading Kids Prime: $e');
    } finally {
      _isLoadingKidsPrime = false;
      notifyListeners();
    }
  }

  // Load Reality TV Prime
  Future<void> loadRealityTvPrime() async {
    _isLoadingRealityTvPrime = true;
    _realityTvPrimeError = null;
    notifyListeners();

    try {
      // Reality TV content on Prime
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en',
        'region': 'US',
        'with_genres': '10764', // Reality
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _realityTvPrime = results;
      _realityTvPrimeError = null;
    } catch (e) {
      _realityTvPrimeError = 'Failed to load Reality TV Prime: $e';
      print('Error loading Reality TV Prime: $e');
    } finally {
      _isLoadingRealityTvPrime = false;
      notifyListeners();
    }
  }

  // Load Game Show Prime
  Future<void> loadGameShowPrime() async {
    _isLoadingGameShowPrime = true;
    _gameShowPrimeError = null;
    notifyListeners();

    try {
      // Game Show content on Prime
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en',
        'region': 'US',
        'with_genres': '10763', // Game Show
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _gameShowPrime = results;
      _gameShowPrimeError = null;
    } catch (e) {
      _gameShowPrimeError = 'Failed to load Game Show Prime: $e';
      print('Error loading Game Show Prime: $e');
    } finally {
      _isLoadingGameShowPrime = false;
      notifyListeners();
    }
  }

  // Load Talk Show Prime
  Future<void> loadTalkShowPrime() async {
    _isLoadingTalkShowPrime = true;
    _talkShowPrimeError = null;
    notifyListeners();

    try {
      // Talk Show content on Prime
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en',
        'region': 'US',
        'with_genres': '10767', // Talk Show
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _talkShowPrime = results;
      _talkShowPrimeError = null;
    } catch (e) {
      _talkShowPrimeError = 'Failed to load Talk Show Prime: $e';
      print('Error loading Talk Show Prime: $e');
    } finally {
      _isLoadingTalkShowPrime = false;
      notifyListeners();
    }
  }

  // Load Variety Prime
  Future<void> loadVarietyPrime() async {
    _isLoadingVarietyPrime = true;
    _varietyPrimeError = null;
    notifyListeners();

    try {
      // Variety content on Prime
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en',
        'region': 'US',
        'with_genres': '10767', // Talk Show (variety shows)
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _varietyPrime = results;
      _varietyPrimeError = null;
    } catch (e) {
      _varietyPrimeError = 'Failed to load Variety Prime: $e';
      print('Error loading Variety Prime: $e');
    } finally {
      _isLoadingVarietyPrime = false;
      notifyListeners();
    }
  }

  // Load News Prime
  Future<void> loadNewsPrime() async {
    _isLoadingNewsPrime = true;
    _newsPrimeError = null;
    notifyListeners();

    try {
      // News content on Prime
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_original_language': 'en',
        'region': 'US',
        'with_genres': '10763', // Game Show (news shows)
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _newsPrime = results;
      _newsPrimeError = null;
    } catch (e) {
      _newsPrimeError = 'Failed to load News Prime: $e';
      print('Error loading News Prime: $e');
    } finally {
      _isLoadingNewsPrime = false;
      notifyListeners();
    }
  }

  // Load Educational Prime
  Future<void> loadEducationalPrime() async {
    _isLoadingEducationalPrime = true;
    _educationalPrimeError = null;
    notifyListeners();

    try {
      // Educational content on Prime
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime provider ID
        'with_genres': '99', // Documentary
        'with_keywords': '180', // Educational
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _educationalPrime = results;
      _educationalPrimeError = null;
    } catch (e) {
      _educationalPrimeError = 'Failed to load Educational Prime: $e';
      print('Error loading Educational Prime: $e');
    } finally {
      _isLoadingEducationalPrime = false;
      notifyListeners();
    }
  }

  // Load Top 250 Movies

  // Load Top Rated Animated
  Future<void> loadTopRatedAnimated() async {
    _isLoadingTopRatedAnimated = true;
    _topRatedAnimatedError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,10751',
        'certification_country': 'US',
        'certification.lte': 'PG',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '100',
        'page': '1',
      });
      _topRatedAnimated = results;
      _topRatedAnimatedError = null;
    } catch (e) {
      _topRatedAnimatedError = 'Failed to load Top Rated Animated: $e';
      print('Error loading Top Rated Animated: $e');
    } finally {
      _isLoadingTopRatedAnimated = false;
      notifyListeners();
    }
  }

  // Load Pixar Animated
  Future<void> loadPixarAnimated() async {
    _isLoadingPixarAnimated = true;
    _pixarAnimatedError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,10751',
        'certification_country': 'US',
        'certification.lte': 'PG',
        'with_companies': '3',
        'page': '1',
      });
      _pixarAnimated = results;
      _pixarAnimatedError = null;
    } catch (e) {
      _pixarAnimatedError = 'Failed to load Pixar Animated: $e';
      print('Error loading Pixar Animated: $e');
    } finally {
      _isLoadingPixarAnimated = false;
      notifyListeners();
    }
  }

  // Load Studio Ghibli Animated
  Future<void> loadGhibliAnimated() async {
    _isLoadingGhibliAnimated = true;
    _ghibliAnimatedError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,10751',
        'certification_country': 'US',
        'certification.lte': 'PG',
        'with_companies': '10342',
        'page': '1',
      });
      _ghibliAnimated = results;
      _ghibliAnimatedError = null;
    } catch (e) {
      _ghibliAnimatedError = 'Failed to load Studio Ghibli Animated: $e';
      print('Error loading Studio Ghibli Animated: $e');
    } finally {
      _isLoadingGhibliAnimated = false;
      notifyListeners();
    }
  }

  // Load Recent & Upcoming Animated
  Future<void> loadRecentUpcomingAnimated() async {
    _isLoadingRecentUpcomingAnimated = true;
    _recentUpcomingAnimatedError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16',
        'primary_release_date.gte': '2020-01-01',
        'primary_release_date.lte': '2025-12-31',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _recentUpcomingAnimated = results;
      _recentUpcomingAnimatedError = null;
    } catch (e) {
      _recentUpcomingAnimatedError =
          'Failed to load Recent & Upcoming Animated: $e';
      print('Error loading Recent & Upcoming Animated: $e');
    } finally {
      _isLoadingRecentUpcomingAnimated = false;
      notifyListeners();
    }
  }

  // Load Popular Animated TV Shows
  Future<void> loadPopularAnimatedTv() async {
    _isLoadingPopularAnimatedTv = true;
    _popularAnimatedTvError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_genres': '16,10751',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _popularAnimatedTv = results;
      _popularAnimatedTvError = null;
    } catch (e) {
      _popularAnimatedTvError = 'Failed to load Popular Animated TV: $e';
      print('Error loading Popular Animated TV: $e');
    } finally {
      _isLoadingPopularAnimatedTv = false;
      notifyListeners();
    }
  }

  // Load New Releases Animated
  Future<void> loadNewReleasesAnimated() async {
    _isLoadingNewReleasesAnimated = true;
    _newReleasesAnimatedError = null;
    notifyListeners();

    try {
      // New animated releases from 2024 onwards
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'primary_release_date.gte': '2024-01-01',
        'sort_by': 'primary_release_date.desc',
        'page': '1',
      });
      _newReleasesAnimated = results;
      _newReleasesAnimatedError = null;
    } catch (e) {
      _newReleasesAnimatedError = 'Failed to load New Releases Animated: $e';
      print('Error loading New Releases Animated: $e');
    } finally {
      _isLoadingNewReleasesAnimated = false;
      notifyListeners();
    }
  }

  // Load Popular Animated
  Future<void> loadPopularAnimated() async {
    _isLoadingPopularAnimated = true;
    _popularAnimatedError = null;
    notifyListeners();

    try {
      // Popular animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'sort_by': 'popularity.desc',
        'vote_count.gte': '200',
        'page': '1',
      });
      _popularAnimated = results;
      _popularAnimatedError = null;
    } catch (e) {
      _popularAnimatedError = 'Failed to load Popular Animated: $e';
      print('Error loading Popular Animated: $e');
    } finally {
      _isLoadingPopularAnimated = false;
      notifyListeners();
    }
  }

  // Load Award Winners Animated
  Future<void> loadAwardWinnersAnimated() async {
    _isLoadingAwardWinnersAnimated = true;
    _awardWinnersAnimatedError = null;
    notifyListeners();

    try {
      // Award-winning animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '500',
        'vote_average.gte': '7.5',
        'page': '1',
      });
      _awardWinnersAnimated = results;
      _awardWinnersAnimatedError = null;
    } catch (e) {
      _awardWinnersAnimatedError = 'Failed to load Award Winners Animated: $e';
      print('Error loading Award Winners Animated: $e');
    } finally {
      _isLoadingAwardWinnersAnimated = false;
      notifyListeners();
    }
  }

  // Load Family Animated
  Future<void> loadFamilyAnimated() async {
    _isLoadingFamilyAnimated = true;
    _familyAnimatedError = null;
    notifyListeners();

    try {
      // Family-friendly animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,10751', // Animation, Family
        'certification_country': 'US',
        'certification.lte': 'PG-13',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _familyAnimated = results;
      _familyAnimatedError = null;
    } catch (e) {
      _familyAnimatedError = 'Failed to load Family Animated: $e';
      print('Error loading Family Animated: $e');
    } finally {
      _isLoadingFamilyAnimated = false;
      notifyListeners();
    }
  }

  // Load Comedy Animated
  Future<void> loadComedyAnimated() async {
    _isLoadingComedyAnimated = true;
    _comedyAnimatedError = null;
    notifyListeners();

    try {
      // Comedy animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,35', // Animation, Comedy
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _comedyAnimated = results;
      _comedyAnimatedError = null;
    } catch (e) {
      _comedyAnimatedError = 'Failed to load Comedy Animated: $e';
      print('Error loading Comedy Animated: $e');
    } finally {
      _isLoadingComedyAnimated = false;
      notifyListeners();
    }
  }

  // Load Adventure Animated
  Future<void> loadAdventureAnimated() async {
    _isLoadingAdventureAnimated = true;
    _adventureAnimatedError = null;
    notifyListeners();

    try {
      // Adventure animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,12', // Animation, Adventure
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _adventureAnimated = results;
      _adventureAnimatedError = null;
    } catch (e) {
      _adventureAnimatedError = 'Failed to load Adventure Animated: $e';
      print('Error loading Adventure Animated: $e');
    } finally {
      _isLoadingAdventureAnimated = false;
      notifyListeners();
    }
  }

  // Load Fantasy Animated
  Future<void> loadFantasyAnimated() async {
    _isLoadingFantasyAnimated = true;
    _fantasyAnimatedError = null;
    notifyListeners();

    try {
      // Fantasy animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,14', // Animation, Fantasy
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _fantasyAnimated = results;
      _fantasyAnimatedError = null;
    } catch (e) {
      _fantasyAnimatedError = 'Failed to load Fantasy Animated: $e';
      print('Error loading Fantasy Animated: $e');
    } finally {
      _isLoadingFantasyAnimated = false;
      notifyListeners();
    }
  }

  // Load Superhero Animated
  Future<void> loadSuperheroAnimated() async {
    _isLoadingSuperheroAnimated = true;
    _superheroAnimatedError = null;
    notifyListeners();

    try {
      // Superhero animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_keywords': '180', // Superhero
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _superheroAnimated = results;
      _superheroAnimatedError = null;
    } catch (e) {
      _superheroAnimatedError = 'Failed to load Superhero Animated: $e';
      print('Error loading Superhero Animated: $e');
    } finally {
      _isLoadingSuperheroAnimated = false;
      notifyListeners();
    }
  }

  // Load Musical Animated
  Future<void> loadMusicalAnimated() async {
    _isLoadingMusicalAnimated = true;
    _musicalAnimatedError = null;
    notifyListeners();

    try {
      // Musical animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,10402', // Animation, Musical
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _musicalAnimated = results;
      _musicalAnimatedError = null;
    } catch (e) {
      _musicalAnimatedError = 'Failed to load Musical Animated: $e';
      print('Error loading Musical Animated: $e');
    } finally {
      _isLoadingMusicalAnimated = false;
      notifyListeners();
    }
  }

  // Load Classic Animated
  Future<void> loadClassicAnimated() async {
    _isLoadingClassicAnimated = true;
    _classicAnimatedError = null;
    notifyListeners();

    try {
      // Classic animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'primary_release_date.lte': '2000-12-31',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '1000',
        'page': '1',
      });
      _classicAnimated = results;
      _classicAnimatedError = null;
    } catch (e) {
      _classicAnimatedError = 'Failed to load Classic Animated: $e';
      print('Error loading Classic Animated: $e');
    } finally {
      _isLoadingClassicAnimated = false;
      notifyListeners();
    }
  }

  // Load Upcoming Animated
  Future<void> loadUpcomingAnimated() async {
    _isLoadingUpcomingAnimated = true;
    _upcomingAnimatedError = null;
    notifyListeners();

    try {
      // Upcoming animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'primary_release_date.gte': '2024-06-01',
        'sort_by': 'primary_release_date.asc',
        'page': '1',
      });
      _upcomingAnimated = results;
      _upcomingAnimatedError = null;
    } catch (e) {
      _upcomingAnimatedError = 'Failed to load Upcoming Animated: $e';
      print('Error loading Upcoming Animated: $e');
    } finally {
      _isLoadingUpcomingAnimated = false;
      notifyListeners();
    }
  }

  // Load Critically Acclaimed Animated
  Future<void> loadCriticallyAcclaimedAnimated() async {
    _isLoadingCriticallyAcclaimedAnimated = true;
    _criticallyAcclaimedAnimatedError = null;
    notifyListeners();

    try {
      // Critically acclaimed animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '300',
        'vote_average.gte': '7.0',
        'page': '1',
      });
      _criticallyAcclaimedAnimated = results;
      _criticallyAcclaimedAnimatedError = null;
    } catch (e) {
      _criticallyAcclaimedAnimatedError =
          'Failed to load Critically Acclaimed Animated: $e';
      print('Error loading Critically Acclaimed Animated: $e');
    } finally {
      _isLoadingCriticallyAcclaimedAnimated = false;
      notifyListeners();
    }
  }

  // Load Indie Animated
  Future<void> loadIndieAnimated() async {
    _isLoadingIndieAnimated = true;
    _indieAnimatedError = null;
    notifyListeners();

    try {
      // Indie animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'vote_count.gte': '50',
        'vote_count.lte': '500',
        'sort_by': 'vote_average.desc',
        'page': '1',
      });
      _indieAnimated = results;
      _indieAnimatedError = null;
    } catch (e) {
      _indieAnimatedError = 'Failed to load Indie Animated: $e';
      print('Error loading Indie Animated: $e');
    } finally {
      _isLoadingIndieAnimated = false;
      notifyListeners();
    }
  }

  // Load Foreign Animated
  Future<void> loadForeignAnimated() async {
    _isLoadingForeignAnimated = true;
    _foreignAnimatedError = null;
    notifyListeners();

    try {
      // Foreign animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_original_language': '!en',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _foreignAnimated = results;
      _foreignAnimatedError = null;
    } catch (e) {
      _foreignAnimatedError = 'Failed to load Foreign Animated: $e';
      print('Error loading Foreign Animated: $e');
    } finally {
      _isLoadingForeignAnimated = false;
      notifyListeners();
    }
  }

  // Load Teen Animated
  Future<void> loadTeenAnimated() async {
    _isLoadingTeenAnimated = true;
    _teenAnimatedError = null;
    notifyListeners();

    try {
      // Teen animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,10749,35', // Animation, Romance, Comedy
        'certification_country': 'US',
        'certification.lte': 'PG-13',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _teenAnimated = results;
      _teenAnimatedError = null;
    } catch (e) {
      _teenAnimatedError = 'Failed to load Teen Animated: $e';
      print('Error loading Teen Animated: $e');
    } finally {
      _isLoadingTeenAnimated = false;
      notifyListeners();
    }
  }

  // Load Kids Animated
  Future<void> loadKidsAnimated() async {
    _isLoadingKidsAnimated = true;
    _kidsAnimatedError = null;
    notifyListeners();

    try {
      // Kids animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16,10751', // Animation, Family
        'certification_country': 'US',
        'certification.lte': 'G',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _kidsAnimated = results;
      _kidsAnimatedError = null;
    } catch (e) {
      _kidsAnimatedError = 'Failed to load Kids Animated: $e';
      print('Error loading Kids Animated: $e');
    } finally {
      _isLoadingKidsAnimated = false;
      notifyListeners();
    }
  }

  // Load Stop Motion Animated
  Future<void> loadStopMotionAnimated() async {
    _isLoadingStopMotionAnimated = true;
    _stopMotionAnimatedError = null;
    notifyListeners();

    try {
      // Stop motion animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_keywords': '123', // Stop motion
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _stopMotionAnimated = results;
      _stopMotionAnimatedError = null;
    } catch (e) {
      _stopMotionAnimatedError = 'Failed to load Stop Motion Animated: $e';
      print('Error loading Stop Motion Animated: $e');
    } finally {
      _isLoadingStopMotionAnimated = false;
      notifyListeners();
    }
  }

  // Load Computer Generated Animated
  Future<void> loadComputerGeneratedAnimated() async {
    _isLoadingComputerGeneratedAnimated = true;
    _computerGeneratedAnimatedError = null;
    notifyListeners();

    try {
      // Computer generated animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_keywords': '124', // Computer animation
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _computerGeneratedAnimated = results;
      _computerGeneratedAnimatedError = null;
    } catch (e) {
      _computerGeneratedAnimatedError =
          'Failed to load Computer Generated Animated: $e';
      print('Error loading Computer Generated Animated: $e');
    } finally {
      _isLoadingComputerGeneratedAnimated = false;
      notifyListeners();
    }
  }

  // Load Hand Drawn Animated
  Future<void> loadHandDrawnAnimated() async {
    _isLoadingHandDrawnAnimated = true;
    _handDrawnAnimatedError = null;
    notifyListeners();

    try {
      // Hand drawn animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_keywords': '125', // Hand drawn
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _handDrawnAnimated = results;
      _handDrawnAnimatedError = null;
    } catch (e) {
      _handDrawnAnimatedError = 'Failed to load Hand Drawn Animated: $e';
      print('Error loading Hand Drawn Animated: $e');
    } finally {
      _isLoadingHandDrawnAnimated = false;
      notifyListeners();
    }
  }

  // Load Anime Animated
  Future<void> loadAnimeAnimated() async {
    _isLoadingAnimeAnimated = true;
    _animeAnimatedError = null;
    notifyListeners();

    try {
      // Anime content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_original_language': 'ja', // Japanese
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _animeAnimated = results;
      _animeAnimatedError = null;
    } catch (e) {
      _animeAnimatedError = 'Failed to load Anime Animated: $e';
      print('Error loading Anime Animated: $e');
    } finally {
      _isLoadingAnimeAnimated = false;
      notifyListeners();
    }
  }

  // Load European Animated
  Future<void> loadEuropeanAnimated() async {
    _isLoadingEuropeanAnimated = true;
    _europeanAnimatedError = null;
    notifyListeners();

    try {
      // European animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_origin_country': 'FR,IT,ES,DE,GB', // European countries
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _europeanAnimated = results;
      _europeanAnimatedError = null;
    } catch (e) {
      _europeanAnimatedError = 'Failed to load European Animated: $e';
      print('Error loading European Animated: $e');
    } finally {
      _isLoadingEuropeanAnimated = false;
      notifyListeners();
    }
  }

  // Load Disney Animated
  Future<void> loadDisneyAnimated() async {
    _isLoadingDisneyAnimated = true;
    _disneyAnimatedError = null;
    notifyListeners();

    try {
      // Disney animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '2', // Disney
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _disneyAnimated = results;
      _disneyAnimatedError = null;
    } catch (e) {
      _disneyAnimatedError = 'Failed to load Disney Animated: $e';
      print('Error loading Disney Animated: $e');
    } finally {
      _isLoadingDisneyAnimated = false;
      notifyListeners();
    }
  }

  // Load Dreamworks Animated
  Future<void> loadDreamworksAnimated() async {
    _isLoadingDreamworksAnimated = true;
    _dreamworksAnimatedError = null;
    notifyListeners();

    try {
      // Dreamworks animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '521', // Dreamworks
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _dreamworksAnimated = results;
      _dreamworksAnimatedError = null;
    } catch (e) {
      _dreamworksAnimatedError = 'Failed to load Dreamworks Animated: $e';
      print('Error loading Dreamworks Animated: $e');
    } finally {
      _isLoadingDreamworksAnimated = false;
      notifyListeners();
    }
  }

  // Load Illumination Animated
  Future<void> loadIlluminationAnimated() async {
    _isLoadingIlluminationAnimated = true;
    _illuminationAnimatedError = null;
    notifyListeners();

    try {
      // Illumination animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '33', // Illumination
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _illuminationAnimated = results;
      _illuminationAnimatedError = null;
    } catch (e) {
      _illuminationAnimatedError = 'Failed to load Illumination Animated: $e';
      print('Error loading Illumination Animated: $e');
    } finally {
      _isLoadingIlluminationAnimated = false;
      notifyListeners();
    }
  }

  // Load Sony Animated
  Future<void> loadSonyAnimated() async {
    _isLoadingSonyAnimated = true;
    _sonyAnimatedError = null;
    notifyListeners();

    try {
      // Sony animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '34', // Sony
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _sonyAnimated = results;
      _sonyAnimatedError = null;
    } catch (e) {
      _sonyAnimatedError = 'Failed to load Sony Animated: $e';
      print('Error loading Sony Animated: $e');
    } finally {
      _isLoadingSonyAnimated = false;
      notifyListeners();
    }
  }

  // Load Warner Animated
  Future<void> loadWarnerAnimated() async {
    _isLoadingWarnerAnimated = true;
    _warnerAnimatedError = null;
    notifyListeners();

    try {
      // Warner animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '17', // Warner
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _warnerAnimated = results;
      _warnerAnimatedError = null;
    } catch (e) {
      _warnerAnimatedError = 'Failed to load Warner Animated: $e';
      print('Error loading Warner Animated: $e');
    } finally {
      _isLoadingWarnerAnimated = false;
      notifyListeners();
    }
  }

  // Load Paramount Animated
  Future<void> loadParamountAnimated() async {
    _isLoadingParamountAnimated = true;
    _paramountAnimatedError = null;
    notifyListeners();

    try {
      // Paramount animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '4', // Paramount
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _paramountAnimated = results;
      _paramountAnimatedError = null;
    } catch (e) {
      _paramountAnimatedError = 'Failed to load Paramount Animated: $e';
      print('Error loading Paramount Animated: $e');
    } finally {
      _isLoadingParamountAnimated = false;
      notifyListeners();
    }
  }

  // Load Universal Animated
  Future<void> loadUniversalAnimated() async {
    _isLoadingUniversalAnimated = true;
    _universalAnimatedError = null;
    notifyListeners();

    try {
      // Universal animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '33', // Universal
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _universalAnimated = results;
      _universalAnimatedError = null;
    } catch (e) {
      _universalAnimatedError = 'Failed to load Universal Animated: $e';
      print('Error loading Universal Animated: $e');
    } finally {
      _isLoadingUniversalAnimated = false;
      notifyListeners();
    }
  }

  // Load Fox Animated
  Future<void> loadFoxAnimated() async {
    _isLoadingFoxAnimated = true;
    _foxAnimatedError = null;
    notifyListeners();

    try {
      // Fox animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_companies': '25', // Fox
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _foxAnimated = results;
      _foxAnimatedError = null;
    } catch (e) {
      _foxAnimatedError = 'Failed to load Fox Animated: $e';
      print('Error loading Fox Animated: $e');
    } finally {
      _isLoadingFoxAnimated = false;
      notifyListeners();
    }
  }

  // Load Manga Animated
  Future<void> loadMangaAnimated() async {
    _isLoadingMangaAnimated = true;
    _mangaAnimatedError = null;
    notifyListeners();

    try {
      // Manga animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'with_keywords': '210024', // Manga
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _mangaAnimated = results;
      _mangaAnimatedError = null;
    } catch (e) {
      _mangaAnimatedError = 'Failed to load Manga Animated: $e';
      print('Error loading Manga Animated: $e');
    } finally {
      _isLoadingMangaAnimated = false;
      notifyListeners();
    }
  }

  // Load Cartoon Network Animated
  Future<void> loadCartoonNetworkAnimated() async {
    _isLoadingCartoonNetworkAnimated = true;
    _cartoonNetworkAnimatedError = null;
    notifyListeners();

    try {
      // Cartoon Network animated content
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_genres': '16,10751', // Animation, Family
        'with_networks': '11', // Cartoon Network
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _cartoonNetworkAnimated = results;
      _cartoonNetworkAnimatedError = null;
    } catch (e) {
      _cartoonNetworkAnimatedError =
          'Failed to load Cartoon Network Animated: $e';
      print('Error loading Cartoon Network Animated: $e');
    } finally {
      _isLoadingCartoonNetworkAnimated = false;
      notifyListeners();
    }
  }

  // Load Nickelodeon Animated
  Future<void> loadNickelodeonAnimated() async {
    _isLoadingNickelodeonAnimated = true;
    _nickelodeonAnimatedError = null;
    notifyListeners();

    try {
      // Nickelodeon animated content
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_genres': '16,10751', // Animation, Family
        'with_networks': '13', // Nickelodeon
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _nickelodeonAnimated = results;
      _nickelodeonAnimatedError = null;
    } catch (e) {
      _nickelodeonAnimatedError = 'Failed to load Nickelodeon Animated: $e';
      print('Error loading Nickelodeon Animated: $e');
    } finally {
      _isLoadingNickelodeonAnimated = false;
      notifyListeners();
    }
  }

  // Load Disney Channel Animated
  Future<void> loadDisneyChannelAnimated() async {
    _isLoadingDisneyChannelAnimated = true;
    _disneyChannelAnimatedError = null;
    notifyListeners();

    try {
      // Disney Channel animated content
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_genres': '16,10751', // Animation, Family
        'with_networks': '14', // Disney Channel
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _disneyChannelAnimated = results;
      _disneyChannelAnimatedError = null;
    } catch (e) {
      _disneyChannelAnimatedError =
          'Failed to load Disney Channel Animated: $e';
      print('Error loading Disney Channel Animated: $e');
    } finally {
      _isLoadingDisneyChannelAnimated = false;
      notifyListeners();
    }
  }

  // Load Netflix Animated
  Future<void> loadNetflixAnimated() async {
    _isLoadingNetflixAnimated = true;
    _netflixAnimatedError = null;
    notifyListeners();

    try {
      // Netflix animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '8', // Netflix
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _netflixAnimated = results;
      _netflixAnimatedError = null;
    } catch (e) {
      _netflixAnimatedError = 'Failed to load Netflix Animated: $e';
      print('Error loading Netflix Animated: $e');
    } finally {
      _isLoadingNetflixAnimated = false;
      notifyListeners();
    }
  }

  // Load Prime Animated
  Future<void> loadPrimeAnimated() async {
    _isLoadingPrimeAnimated = true;
    _primeAnimatedError = null;
    notifyListeners();

    try {
      // Prime animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '9', // Prime
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _primeAnimated = results;
      _primeAnimatedError = null;
    } catch (e) {
      _primeAnimatedError = 'Failed to load Prime Animated: $e';
      print('Error loading Prime Animated: $e');
    } finally {
      _isLoadingPrimeAnimated = false;
      notifyListeners();
    }
  }

  // Load Hulu Animated
  Future<void> loadHuluAnimated() async {
    _isLoadingHuluAnimated = true;
    _huluAnimatedError = null;
    notifyListeners();

    try {
      // Hulu animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '15', // Hulu
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _huluAnimated = results;
      _huluAnimatedError = null;
    } catch (e) {
      _huluAnimatedError = 'Failed to load Hulu Animated: $e';
      print('Error loading Hulu Animated: $e');
    } finally {
      _isLoadingHuluAnimated = false;
      notifyListeners();
    }
  }

  // Load HBO Animated
  Future<void> loadHboAnimated() async {
    _isLoadingHboAnimated = true;
    _hboAnimatedError = null;
    notifyListeners();

    try {
      // HBO animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '384', // HBO
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _hboAnimated = results;
      _hboAnimatedError = null;
    } catch (e) {
      _hboAnimatedError = 'Failed to load HBO Animated: $e';
      print('Error loading HBO Animated: $e');
    } finally {
      _isLoadingHboAnimated = false;
      notifyListeners();
    }
  }

  // Load Apple Animated
  Future<void> loadAppleAnimated() async {
    _isLoadingAppleAnimated = true;
    _appleAnimatedError = null;
    notifyListeners();

    try {
      // Apple animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '350', // Apple TV+
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _appleAnimated = results;
      _appleAnimatedError = null;
    } catch (e) {
      _appleAnimatedError = 'Failed to load Apple Animated: $e';
      print('Error loading Apple Animated: $e');
    } finally {
      _isLoadingAppleAnimated = false;
      notifyListeners();
    }
  }

  // Load Peacock Animated
  Future<void> loadPeacockAnimated() async {
    _isLoadingPeacockAnimated = true;
    _peacockAnimatedError = null;
    notifyListeners();

    try {
      // Peacock animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '386', // Peacock
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _peacockAnimated = results;
      _peacockAnimatedError = null;
    } catch (e) {
      _peacockAnimatedError = 'Failed to load Peacock Animated: $e';
      print('Error loading Peacock Animated: $e');
    } finally {
      _isLoadingPeacockAnimated = false;
      notifyListeners();
    }
  }

  // Load Paramount Plus Animated
  Future<void> loadParamountPlusAnimated() async {
    _isLoadingParamountPlusAnimated = true;
    _paramountPlusAnimatedError = null;
    notifyListeners();

    try {
      // Paramount Plus animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '531', // Paramount Plus
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _paramountPlusAnimated = results;
      _paramountPlusAnimatedError = null;
    } catch (e) {
      _paramountPlusAnimatedError =
          'Failed to load Paramount Plus Animated: $e';
      print('Error loading Paramount Plus Animated: $e');
    } finally {
      _isLoadingParamountPlusAnimated = false;
      notifyListeners();
    }
  }

  // Load Disney Plus Animated
  Future<void> loadDisneyPlusAnimated() async {
    _isLoadingDisneyPlusAnimated = true;
    _disneyPlusAnimatedError = null;
    notifyListeners();

    try {
      // Disney Plus animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '2', // Disney Plus
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _disneyPlusAnimated = results;
      _disneyPlusAnimatedError = null;
    } catch (e) {
      _disneyPlusAnimatedError = 'Failed to load Disney Plus Animated: $e';
      print('Error loading Disney Plus Animated: $e');
    } finally {
      _isLoadingDisneyPlusAnimated = false;
      notifyListeners();
    }
  }

  // Load Max Animated
  Future<void> loadMaxAnimated() async {
    _isLoadingMaxAnimated = true;
    _maxAnimatedError = null;
    notifyListeners();

    try {
      // Max animated content
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '16', // Animation
        'watch_region': 'US',
        'with_watch_monetization_types': 'flatrate',
        'with_watch_providers': '384', // Max (HBO)
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _maxAnimated = results;
      _maxAnimatedError = null;
    } catch (e) {
      _maxAnimatedError = 'Failed to load Max Animated: $e';
      print('Error loading Max Animated: $e');
    } finally {
      _isLoadingMaxAnimated = false;
      notifyListeners();
    }
  }

  // Load Mindfucks

  // Load Top Rated Documentaries
  Future<void> loadTopRatedDocumentaries() async {
    _isLoadingTopRatedDocumentaries = true;
    _topRatedDocumentariesError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '99',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': '100',
        'page': '1',
      });
      _topRatedDocumentaries = results;
      _topRatedDocumentariesError = null;
    } catch (e) {
      _topRatedDocumentariesError =
          'Failed to load Top Rated Documentaries: $e';
      print('Error loading Top Rated Documentaries: $e');
    } finally {
      _isLoadingTopRatedDocumentaries = false;
      notifyListeners();
    }
  }

  // Load Recent Documentaries
  Future<void> loadRecentDocumentaries() async {
    _isLoadingRecentDocumentaries = true;
    _recentDocumentariesError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '99',
        'primary_release_date.gte': '2022-01-01',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _recentDocumentaries = results;
      _recentDocumentariesError = null;
    } catch (e) {
      _recentDocumentariesError = 'Failed to load Recent Documentaries: $e';
      print('Error loading Recent Documentaries: $e');
    } finally {
      _isLoadingRecentDocumentaries = false;
      notifyListeners();
    }
  }

  // Load Biographical Documentaries
  Future<void> loadBioDocumentaries() async {
    _isLoadingBioDocumentaries = true;
    _bioDocumentariesError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_keywords': '9844',
        'page': '1',
      });
      _bioDocumentaries = results;
      _bioDocumentariesError = null;
    } catch (e) {
      _bioDocumentariesError = 'Failed to load Biographical Documentaries: $e';
      print('Error loading Biographical Documentaries: $e');
    } finally {
      _isLoadingBioDocumentaries = false;
      notifyListeners();
    }
  }

  // Load Netflix Documentaries
  Future<void> loadNetflixDocumentaries() async {
    _isLoadingNetflixDocumentaries = true;
    _netflixDocumentariesError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '99',
        'with_watch_providers': '8',
        'watch_region': 'US',
        'page': '1',
      });
      _netflixDocumentaries = results;
      _netflixDocumentariesError = null;
    } catch (e) {
      _netflixDocumentariesError = 'Failed to load Netflix Documentaries: $e';
      print('Error loading Netflix Documentaries: $e');
    } finally {
      _isLoadingNetflixDocumentaries = false;
      notifyListeners();
    }
  }

  // Load Prime Documentaries
  Future<void> loadPrimeDocumentaries() async {
    _isLoadingPrimeDocumentaries = true;
    _primeDocumentariesError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/movie', {
        'with_genres': '99',
        'with_watch_providers': '9',
        'watch_region': 'US',
        'page': '1',
      });
      _primeDocumentaries = results;
      _primeDocumentariesError = null;
    } catch (e) {
      _primeDocumentariesError = 'Failed to load Prime Documentaries: $e';
      print('Error loading Prime Documentaries: $e');
    } finally {
      _isLoadingPrimeDocumentaries = false;
      notifyListeners();
    }
  }

  // Load Popular Docuseries
  Future<void> loadPopularDocuseries() async {
    _isLoadingPopularDocuseries = true;
    _popularDocuseriesError = null;
    notifyListeners();

    try {
      final results = await TMDBService.fetchCustomData('/discover/tv', {
        'with_genres': '99',
        'sort_by': 'popularity.desc',
        'page': '1',
      });
      _popularDocuseries = results;
      _popularDocuseriesError = null;
    } catch (e) {
      _popularDocuseriesError = 'Failed to load Popular Docuseries: $e';
      print('Error loading Popular Docuseries: $e');
    } finally {
      _isLoadingPopularDocuseries = false;
      notifyListeners();
    }
  }

  // Load Top 250 Catalogue

  // Refresh Top 250 Catalogue

  // Load Animated Catalogue
  Future<void> loadAnimatedCatalogue() async {
    await Future.wait([
      loadTopRatedAnimated(),
      loadPixarAnimated(),
      loadGhibliAnimated(),
      loadRecentUpcomingAnimated(),
      loadPopularAnimatedTv(),
      loadNewReleasesAnimated(),
      loadPopularAnimated(),
      loadAwardWinnersAnimated(),
      loadFamilyAnimated(),
      loadComedyAnimated(),
      loadAdventureAnimated(),
      loadFantasyAnimated(),
      loadSuperheroAnimated(),
      loadMusicalAnimated(),
      loadClassicAnimated(),
      loadUpcomingAnimated(),
      loadCriticallyAcclaimedAnimated(),
      loadIndieAnimated(),
      loadForeignAnimated(),
      loadTeenAnimated(),
      loadKidsAnimated(),
      loadStopMotionAnimated(),
      loadComputerGeneratedAnimated(),
      loadHandDrawnAnimated(),
      loadAnimeAnimated(),
      loadEuropeanAnimated(),
      loadDisneyAnimated(),
      loadDreamworksAnimated(),
      loadIlluminationAnimated(),
      loadSonyAnimated(),
      loadWarnerAnimated(),
      loadParamountAnimated(),
      loadUniversalAnimated(),
      loadFoxAnimated(),
      loadMangaAnimated(),
      loadCartoonNetworkAnimated(),
      loadNickelodeonAnimated(),
      loadDisneyChannelAnimated(),
      loadNetflixAnimated(),
      loadPrimeAnimated(),
      loadHuluAnimated(),
      loadHboAnimated(),
      loadAppleAnimated(),
      loadPeacockAnimated(),
      loadParamountPlusAnimated(),
      loadDisneyPlusAnimated(),
      loadMaxAnimated(),
    ]);
  }

  // Refresh Animated Catalogue
  Future<void> refreshAnimatedCatalogue() async {
    await loadAnimatedCatalogue();
  }

  // Load Mindfucks Catalogue

  // Refresh Mindfucks Catalogue

  // Load Documentaries Catalogue
  Future<void> loadDocumentariesCatalogue() async {
    await Future.wait([
      loadTopRatedDocumentaries(),
      loadRecentDocumentaries(),
      loadBioDocumentaries(),
      loadNetflixDocumentaries(),
      loadPrimeDocumentaries(),
      loadPopularDocuseries(),
    ]);
  }

  // Refresh Documentaries Catalogue
  Future<void> refreshDocumentariesCatalogue() async {
    await loadDocumentariesCatalogue();
  }

  // Search functionality
  Future<void> searchMedia(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      // Search both movies and TV shows
      final movieResults = await TMDBService.searchMedia(query, 'movie');
      final tvResults = await TMDBService.searchMedia(query, 'tv');

      // Combine and remove duplicates
      final combined = [...movieResults, ...tvResults];
      final seen = <int>{};
      _searchResults = combined.where((item) {
        if (item.id == null) return false;
        final duplicate = seen.contains(item.id!);
        seen.add(item.id!);
        return !duplicate;
      }).toList();

      _searchError = null;
    } catch (e) {
      _searchError = 'Search failed: $e';
      print('Search error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshCatalogue() async {
    await loadCatalogue();
  }

  // Get media by ID
  Media? getMediaById(int id) {
    final allMedia = [
      ..._popularNow,
      ..._newlyReleased,
      ..._mostPopular,
      ..._topRatedMovies,
      ..._topRatedTvShows,
      ..._actionAdventure,
      ..._comedy,
      ..._scifiFantasy,
      ..._horror,
      ..._thriller,
      ..._drama,
      ..._romance,
      ..._animation,
      ..._family,
      ..._documentary,
      ..._crime,
      ..._mystery,
      ..._war,
      ..._western,
      ..._music,
      ..._history,
      ..._upcoming,
      ..._awardWinners,
      ..._indie,
      ..._foreign,
      ..._classics,
      ..._teen,
      ..._searchResults,
      ..._latestBollywood,
      ..._classicsBollywood,
      ..._netflixBollywood,
      ..._primeBollywood,
      ..._actionBollywood,
      ..._romanceBollywood,
      ..._thrillerBollywood,
      ..._popularHindiTv,
      ..._topRatedHindiTv,
      ..._newReleasesBollywood,
      ..._blockbusterHitsBollywood,
      ..._criticallyAcclaimedBollywood,
      ..._familyEntertainmentBollywood,
      ..._comedyGoldBollywood,
      ..._actionThrillersBollywood,
      ..._romanticDramasBollywood,
      ..._mysteryCrimeBollywood,
      ..._biographicalBollywood,
      ..._webSeriesBollywood,
      ..._upcomingBollywood,
      ..._awardWinnersBollywood,
      ..._latestKorean,
      ..._topRatedKorean,
      ..._actionKorean,
      ..._thrillerKorean,
      ..._popularKoreanTv,
      ..._topRatedKoreanTv,
      ..._featuredKorean,
      ..._newReleasesKorean,
      ..._blockbusterHitsKorean,
      ..._criticallyAcclaimedKorean,
      ..._familyEntertainmentKorean,
      ..._comedyGoldKorean,
      ..._romanticDramasKorean,
      ..._mysteryCrimeKorean,
      ..._biographicalKorean,
      ..._webSeriesKorean,
      ..._upcomingKorean,
      ..._awardWinnersKorean,
      ..._koreanClassics,
      ..._topRatedNetflix,
      ..._actionNetflix,
      ..._comedyNetflix,
      ..._dramaNetflix,
      ..._thrillerNetflix,
      ..._horrorNetflix,
      ..._scifiNetflix,
      ..._newReleasesNetflix,
      ..._popularNetflix,
      ..._awardWinnersNetflix,
      ..._familyContentNetflix,
      ..._romanceNetflix,
      ..._mysteryNetflix,
      ..._crimeNetflix,
      ..._animationNetflix,
      ..._documentaryNetflix,
      ..._internationalNetflix,
      ..._classicNetflix,
      ..._upcomingNetflix,
      ..._criticallyAcclaimedNetflix,
      ..._topRatedPrime,
      ..._actionPrime,
      ..._comedyPrime,
      ..._dramaPrime,
      ..._thrillerPrime,
      ..._scifiPrime,
      ..._romancePrime,
      ..._popularTvPrime,
      ..._comedyTvPrime,
      ..._dramaTvPrime,
      ..._newReleasesPrime,
      ..._popularPrime,
      ..._awardWinnersPrime,
      ..._familyContentPrime,
      ..._mysteryPrime,
      ..._crimePrime,
      ..._animationPrime,
      ..._documentaryPrime,
      ..._internationalPrime,
      ..._classicPrime,
      ..._upcomingPrime,
      ..._criticallyAcclaimedPrime,
      ..._horrorPrime,
      ..._warPrime,
      ..._westernPrime,
      ..._musicalPrime,
      ..._biographicalPrime,
      ..._sportsPrime,
      ..._adventurePrime,
      ..._fantasyPrime,
      ..._superheroPrime,
      ..._indiePrime,
      ..._foreignPrime,
      ..._teenPrime,
      ..._kidsPrime,
      ..._realityTvPrime,
      ..._gameShowPrime,
      ..._talkShowPrime,
      ..._varietyPrime,
      ..._newsPrime,
      ..._educationalPrime,
      ..._topRatedAnimated,
      ..._pixarAnimated,
      ..._ghibliAnimated,
      ..._recentUpcomingAnimated,
      ..._popularAnimatedTv,
      ..._newReleasesAnimated,
      ..._popularAnimated,
      ..._awardWinnersAnimated,
      ..._familyAnimated,
      ..._comedyAnimated,
      ..._adventureAnimated,
      ..._fantasyAnimated,
      ..._superheroAnimated,
      ..._musicalAnimated,
      ..._classicAnimated,
      ..._upcomingAnimated,
      ..._criticallyAcclaimedAnimated,
      ..._indieAnimated,
      ..._foreignAnimated,
      ..._teenAnimated,
      ..._kidsAnimated,
      ..._stopMotionAnimated,
      ..._computerGeneratedAnimated,
      ..._handDrawnAnimated,
      ..._animeAnimated,
      ..._europeanAnimated,
      ..._disneyAnimated,
      ..._dreamworksAnimated,
      ..._illuminationAnimated,
      ..._sonyAnimated,
      ..._warnerAnimated,
      ..._paramountAnimated,
      ..._universalAnimated,
      ..._foxAnimated,
      ..._mangaAnimated,
      ..._cartoonNetworkAnimated,
      ..._nickelodeonAnimated,
      ..._disneyChannelAnimated,
      ..._netflixAnimated,
      ..._primeAnimated,
      ..._huluAnimated,
      ..._hboAnimated,
      ..._appleAnimated,
      ..._peacockAnimated,
      ..._paramountPlusAnimated,
      ..._disneyPlusAnimated,
      ..._maxAnimated,
      ..._topRatedDocumentaries,
      ..._recentDocumentaries,
      ..._bioDocumentaries,
      ..._netflixDocumentaries,
      ..._primeDocumentaries,
      ..._popularDocuseries,
    ];

    try {
      return allMedia.firstWhere((media) => media.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if any category is loading
  bool get isAnyLoading =>
      _isLoadingPopular ||
      _isLoadingNewlyReleased ||
      _isLoadingMostPopular ||
      _isLoadingTopRatedMovies ||
      _isLoadingTopRatedTvShows ||
      _isLoadingActionAdventure ||
      _isLoadingComedy ||
      _isLoadingScifiFantasy ||
      _isLoadingHorror ||
      _isLoadingThriller ||
      _isLoadingDrama ||
      _isLoadingRomance ||
      _isLoadingAnimation ||
      _isLoadingFamily ||
      _isLoadingDocumentary ||
      _isLoadingCrime ||
      _isLoadingMystery ||
      _isLoadingWar ||
      _isLoadingWestern ||
      _isLoadingMusic ||
      _isLoadingHistory ||
      _isLoadingUpcoming ||
      _isLoadingAwardWinners ||
      _isLoadingIndie ||
      _isLoadingForeign ||
      _isLoadingClassics ||
      _isLoadingTeen ||
      _isSearching ||
      _isLoadingLatestBollywood ||
      _isLoadingClassicsBollywood ||
      _isLoadingNetflixBollywood ||
      _isLoadingPrimeBollywood ||
      _isLoadingActionBollywood ||
      _isLoadingRomanceBollywood ||
      _isLoadingThrillerBollywood ||
      _isLoadingPopularHindiTv ||
      _isLoadingTopRatedHindiTv ||
      _isLoadingNewReleasesBollywood ||
      _isLoadingBlockbusterHitsBollywood ||
      _isLoadingCriticallyAcclaimedBollywood ||
      _isLoadingFamilyEntertainmentBollywood ||
      _isLoadingComedyGoldBollywood ||
      _isLoadingActionThrillersBollywood ||
      _isLoadingRomanticDramasBollywood ||
      _isLoadingMysteryCrimeBollywood ||
      _isLoadingBiographicalBollywood ||
      _isLoadingWebSeriesBollywood ||
      _isLoadingUpcomingBollywood ||
      _isLoadingAwardWinnersBollywood ||
      _isLoadingLatestKorean ||
      _isLoadingTopRatedKorean ||
      _isLoadingActionKorean ||
      _isLoadingThrillerKorean ||
      _isLoadingPopularKoreanTv ||
      _isLoadingTopRatedKoreanTv ||
      _isLoadingFeaturedKorean ||
      _isLoadingNewReleasesKorean ||
      _isLoadingBlockbusterHitsKorean ||
      _isLoadingCriticallyAcclaimedKorean ||
      _isLoadingFamilyEntertainmentKorean ||
      _isLoadingComedyGoldKorean ||
      _isLoadingRomanticDramasKorean ||
      _isLoadingMysteryCrimeKorean ||
      _isLoadingBiographicalKorean ||
      _isLoadingWebSeriesKorean ||
      _isLoadingUpcomingKorean ||
      _isLoadingAwardWinnersKorean ||
      _isLoadingKoreanClassics ||
      _isLoadingTopRatedNetflix ||
      _isLoadingActionNetflix ||
      _isLoadingComedyNetflix ||
      _isLoadingDramaNetflix ||
      _isLoadingThrillerNetflix ||
      _isLoadingHorrorNetflix ||
      _isLoadingScifiNetflix ||
      _isLoadingNewReleasesNetflix ||
      _isLoadingPopularNetflix ||
      _isLoadingAwardWinnersNetflix ||
      _isLoadingFamilyContentNetflix ||
      _isLoadingRomanceNetflix ||
      _isLoadingMysteryNetflix ||
      _isLoadingCrimeNetflix ||
      _isLoadingAnimationNetflix ||
      _isLoadingDocumentaryNetflix ||
      _isLoadingInternationalNetflix ||
      _isLoadingClassicNetflix ||
      _isLoadingUpcomingNetflix ||
      _isLoadingCriticallyAcclaimedNetflix ||
      _isLoadingTopRatedPrime ||
      _isLoadingActionPrime ||
      _isLoadingComedyPrime ||
      _isLoadingDramaPrime ||
      _isLoadingThrillerPrime ||
      _isLoadingScifiPrime ||
      _isLoadingRomancePrime ||
      _isLoadingPopularTvPrime ||
      _isLoadingComedyTvPrime ||
      _isLoadingDramaTvPrime ||
      _isLoadingNewReleasesPrime ||
      _isLoadingPopularPrime ||
      _isLoadingAwardWinnersPrime ||
      _isLoadingFamilyContentPrime ||
      _isLoadingMysteryPrime ||
      _isLoadingCrimePrime ||
      _isLoadingAnimationPrime ||
      _isLoadingDocumentaryPrime ||
      _isLoadingInternationalPrime ||
      _isLoadingClassicPrime ||
      _isLoadingUpcomingPrime ||
      _isLoadingCriticallyAcclaimedPrime ||
      _isLoadingHorrorPrime ||
      _isLoadingWarPrime ||
      _isLoadingWesternPrime ||
      _isLoadingMusicalPrime ||
      _isLoadingBiographicalPrime ||
      _isLoadingSportsPrime ||
      _isLoadingAdventurePrime ||
      _isLoadingFantasyPrime ||
      _isLoadingSuperheroPrime ||
      _isLoadingIndiePrime ||
      _isLoadingForeignPrime ||
      _isLoadingTeenPrime ||
      _isLoadingKidsPrime ||
      _isLoadingRealityTvPrime ||
      _isLoadingGameShowPrime ||
      _isLoadingTalkShowPrime ||
      _isLoadingVarietyPrime ||
      _isLoadingNewsPrime ||
      _isLoadingEducationalPrime ||
      _isLoadingTopRatedAnimated ||
      _isLoadingPixarAnimated ||
      _isLoadingGhibliAnimated ||
      _isLoadingRecentUpcomingAnimated ||
      _isLoadingPopularAnimatedTv ||
      _isLoadingNewReleasesAnimated ||
      _isLoadingPopularAnimated ||
      _isLoadingAwardWinnersAnimated ||
      _isLoadingFamilyAnimated ||
      _isLoadingComedyAnimated ||
      _isLoadingAdventureAnimated ||
      _isLoadingFantasyAnimated ||
      _isLoadingSuperheroAnimated ||
      _isLoadingMusicalAnimated ||
      _isLoadingClassicAnimated ||
      _isLoadingUpcomingAnimated ||
      _isLoadingCriticallyAcclaimedAnimated ||
      _isLoadingIndieAnimated ||
      _isLoadingForeignAnimated ||
      _isLoadingTeenAnimated ||
      _isLoadingKidsAnimated ||
      _isLoadingStopMotionAnimated ||
      _isLoadingComputerGeneratedAnimated ||
      _isLoadingHandDrawnAnimated ||
      _isLoadingAnimeAnimated ||
      _isLoadingEuropeanAnimated ||
      _isLoadingDisneyAnimated ||
      _isLoadingDreamworksAnimated ||
      _isLoadingIlluminationAnimated ||
      _isLoadingSonyAnimated ||
      _isLoadingWarnerAnimated ||
      _isLoadingParamountAnimated ||
      _isLoadingUniversalAnimated ||
      _isLoadingFoxAnimated ||
      _isLoadingMangaAnimated ||
      _isLoadingCartoonNetworkAnimated ||
      _isLoadingNickelodeonAnimated ||
      _isLoadingDisneyChannelAnimated ||
      _isLoadingNetflixAnimated ||
      _isLoadingPrimeAnimated ||
      _isLoadingHuluAnimated ||
      _isLoadingHboAnimated ||
      _isLoadingAppleAnimated ||
      _isLoadingPeacockAnimated ||
      _isLoadingParamountPlusAnimated ||
      _isLoadingDisneyPlusAnimated ||
      _isLoadingMaxAnimated ||
      _isLoadingTopRatedDocumentaries ||
      _isLoadingRecentDocumentaries ||
      _isLoadingBioDocumentaries ||
      _isLoadingNetflixDocumentaries ||
      _isLoadingPrimeDocumentaries ||
      _isLoadingPopularDocuseries;

  // Check if any category has errors
  bool get hasAnyErrors =>
      _popularError != null ||
      _newlyReleasedError != null ||
      _mostPopularError != null ||
      _topRatedMoviesError != null ||
      _topRatedTvShowsError != null ||
      _actionAdventureError != null ||
      _comedyError != null ||
      _scifiFantasyError != null ||
      _horrorError != null ||
      _thrillerError != null ||
      _dramaError != null ||
      _romanceError != null ||
      _animationError != null ||
      _familyError != null ||
      _documentaryError != null ||
      _crimeError != null ||
      _mysteryError != null ||
      _warError != null ||
      _westernError != null ||
      _musicError != null ||
      _historyError != null ||
      _upcomingError != null ||
      _awardWinnersError != null ||
      _indieError != null ||
      _foreignError != null ||
      _classicsError != null ||
      _teenError != null ||
      _latestBollywoodError != null ||
      _classicsBollywoodError != null ||
      _netflixBollywoodError != null ||
      _primeBollywoodError != null ||
      _actionBollywoodError != null ||
      _romanceBollywoodError != null ||
      _thrillerBollywoodError != null ||
      _popularHindiTvError != null ||
      _topRatedHindiTvError != null ||
      _newReleasesBollywoodError != null ||
      _blockbusterHitsBollywoodError != null ||
      _criticallyAcclaimedBollywoodError != null ||
      _familyEntertainmentBollywoodError != null ||
      _comedyGoldBollywoodError != null ||
      _actionThrillersBollywoodError != null ||
      _romanticDramasBollywoodError != null ||
      _mysteryCrimeBollywoodError != null ||
      _biographicalBollywoodError != null ||
      _webSeriesBollywoodError != null ||
      _upcomingBollywoodError != null ||
      _awardWinnersBollywoodError != null ||
      _latestKoreanError != null ||
      _topRatedKoreanError != null ||
      _actionKoreanError != null ||
      _thrillerKoreanError != null ||
      _popularKoreanTvError != null ||
      _topRatedKoreanTvError != null ||
      _featuredKoreanError != null ||
      _newReleasesKoreanError != null ||
      _blockbusterHitsKoreanError != null ||
      _criticallyAcclaimedKoreanError != null ||
      _familyEntertainmentKoreanError != null ||
      _comedyGoldKoreanError != null ||
      _romanticDramasKoreanError != null ||
      _mysteryCrimeKoreanError != null ||
      _biographicalKoreanError != null ||
      _webSeriesKoreanError != null ||
      _upcomingKoreanError != null ||
      _awardWinnersKoreanError != null ||
      _koreanClassicsError != null ||
      _topRatedNetflixError != null ||
      _actionNetflixError != null ||
      _comedyNetflixError != null ||
      _dramaNetflixError != null ||
      _thrillerNetflixError != null ||
      _horrorNetflixError != null ||
      _scifiNetflixError != null ||
      _newReleasesNetflixError != null ||
      _popularNetflixError != null ||
      _awardWinnersNetflixError != null ||
      _familyContentNetflixError != null ||
      _romanceNetflixError != null ||
      _mysteryNetflixError != null ||
      _crimeNetflixError != null ||
      _animationNetflixError != null ||
      _documentaryNetflixError != null ||
      _internationalNetflixError != null ||
      _classicNetflixError != null ||
      _upcomingNetflixError != null ||
      _criticallyAcclaimedNetflixError != null ||
      _topRatedPrimeError != null ||
      _actionPrimeError != null ||
      _comedyPrimeError != null ||
      _dramaPrimeError != null ||
      _thrillerPrimeError != null ||
      _scifiPrimeError != null ||
      _romancePrimeError != null ||
      _popularTvPrimeError != null ||
      _comedyTvPrimeError != null ||
      _dramaTvPrimeError != null ||
      _newReleasesPrimeError != null ||
      _popularPrimeError != null ||
      _awardWinnersPrimeError != null ||
      _familyContentPrimeError != null ||
      _mysteryPrimeError != null ||
      _crimePrimeError != null ||
      _animationPrimeError != null ||
      _documentaryPrimeError != null ||
      _internationalPrimeError != null ||
      _classicPrimeError != null ||
      _upcomingPrimeError != null ||
      _criticallyAcclaimedPrimeError != null ||
      _horrorPrimeError != null ||
      _warPrimeError != null ||
      _westernPrimeError != null ||
      _musicalPrimeError != null ||
      _biographicalPrimeError != null ||
      _sportsPrimeError != null ||
      _adventurePrimeError != null ||
      _fantasyPrimeError != null ||
      _superheroPrimeError != null ||
      _indiePrimeError != null ||
      _foreignPrimeError != null ||
      _teenPrimeError != null ||
      _kidsPrimeError != null ||
      _realityTvPrimeError != null ||
      _gameShowPrimeError != null ||
      _talkShowPrimeError != null ||
      _varietyPrimeError != null ||
      _newsPrimeError != null ||
      _educationalPrimeError != null ||
      _topRatedAnimatedError != null ||
      _pixarAnimatedError != null ||
      _ghibliAnimatedError != null ||
      _recentUpcomingAnimatedError != null ||
      _popularAnimatedTvError != null ||
      _newReleasesAnimatedError != null ||
      _popularAnimatedError != null ||
      _awardWinnersAnimatedError != null ||
      _familyAnimatedError != null ||
      _comedyAnimatedError != null ||
      _adventureAnimatedError != null ||
      _fantasyAnimatedError != null ||
      _superheroAnimatedError != null ||
      _musicalAnimatedError != null ||
      _classicAnimatedError != null ||
      _upcomingAnimatedError != null ||
      _criticallyAcclaimedAnimatedError != null ||
      _indieAnimatedError != null ||
      _foreignAnimatedError != null ||
      _teenAnimatedError != null ||
      _kidsAnimatedError != null ||
      _stopMotionAnimatedError != null ||
      _computerGeneratedAnimatedError != null ||
      _handDrawnAnimatedError != null ||
      _animeAnimatedError != null ||
      _europeanAnimatedError != null ||
      _disneyAnimatedError != null ||
      _dreamworksAnimatedError != null ||
      _illuminationAnimatedError != null ||
      _sonyAnimatedError != null ||
      _warnerAnimatedError != null ||
      _paramountAnimatedError != null ||
      _universalAnimatedError != null ||
      _foxAnimatedError != null ||
      _mangaAnimatedError != null ||
      _cartoonNetworkAnimatedError != null ||
      _nickelodeonAnimatedError != null ||
      _disneyChannelAnimatedError != null ||
      _netflixAnimatedError != null ||
      _primeAnimatedError != null ||
      _huluAnimatedError != null ||
      _hboAnimatedError != null ||
      _appleAnimatedError != null ||
      _peacockAnimatedError != null ||
      _paramountPlusAnimatedError != null ||
      _disneyPlusAnimatedError != null ||
      _maxAnimatedError != null ||
      _topRatedDocumentariesError != null ||
      _recentDocumentariesError != null ||
      _bioDocumentariesError != null ||
      _netflixDocumentariesError != null ||
      _primeDocumentariesError != null ||
      _popularDocuseriesError != null;
}
