import React from 'react';

export function Footer() {
  return (
    <footer className="mt-auto border-t border-border/20 py-8">
      <div className="container mx-auto px-4 text-center text-muted-foreground">
        <p>&copy; {new Date().getFullYear()} Movora. All Rights Reserved.</p>
        <p className="text-sm mt-2">
          This project uses the TMDB API but is not endorsed or certified by TMDB.
        </p>
        <p className="text-xs mt-4 max-w-3xl mx-auto">
          Movora is a search engine for streaming links and does not host any files on its servers. All content is provided by non-affiliated third parties. Copyright infringement claims should be directed to the content hosting sites.
        </p>
      </div>
    </footer>
  );
}
