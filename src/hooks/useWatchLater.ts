'use client';

import { useState, useEffect, useCallback } from 'react';
import { toast } from './use-toast';
import type { Media } from '@/types/tmdb';

const WATCH_LATER_KEY = 'movoraWatchLater';

export function useWatchLater() {
  const [watchLater, setWatchLater] = useState<Media[]>([]);
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
    try {
      const items = window.localStorage.getItem(WATCH_LATER_KEY);
      setWatchLater(items ? JSON.parse(items) : []);
    } catch (error) {
      console.error('Failed to load watch later list from localStorage', error);
      setWatchLater([]);
    }
  }, []);

  const updateLocalStorage = (items: Media[]) => {
    try {
      window.localStorage.setItem(WATCH_LATER_KEY, JSON.stringify(items));
    } catch (error) {
      console.error('Failed to save watch later list to localStorage', error);
    }
  };

  const addToWatchLater = (item: Media) => {
    const newWatchLater = [...watchLater, item];
    setWatchLater(newWatchLater);
    updateLocalStorage(newWatchLater);
    toast({
      title: 'Added to Watch Later',
      description: `"${'title' in item ? item.title : item.name}" has been added to your list.`,
    });
  };

  const removeFromWatchLater = (id: number, media_type: 'movie' | 'tv') => {
    const item = watchLater.find(i => i.id === id && i.media_type === media_type);
    const newWatchLater = watchLater.filter(i => !(i.id === id && i.media_type === media_type));
    setWatchLater(newWatchLater);
    updateLocalStorage(newWatchLater);
     if (item) {
        toast({
            title: 'Removed from Watch Later',
            description: `"${'title' in item ? item.title : item.name}" has been removed from your list.`,
            variant: 'destructive',
        });
     }
  };

  const isInWatchLater = useCallback((id: number, media_type: 'movie' | 'tv') => {
    return watchLater.some(item => item.id === id && item.media_type === media_type);
  }, [watchLater]);

  return { watchLater, addToWatchLater, removeFromWatchLater, isInWatchLater, isClient };
}
