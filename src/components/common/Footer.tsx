import React from 'react';

export function Footer() {
  return (
    <footer className="mt-auto border-t border-border/20 py-8">
      <div className="container mx-auto px-4 text-center text-muted-foreground">
        <p>&copy; {new Date().getFullYear()} Movora. All Rights Reserved.</p>
        <p className="text-sm mt-2">
          This project uses the TMDB API but is not endorsed or certified by TMDB.
        </p>
        <p className="text-xs mt-4 max-w-4xl mx-auto">
            DMCA Disclaimer: Movora is a content aggregator that scrapes publicly available sources from the internet. We do not host, upload, or store any copyrighted content on our servers. All videos, images, and links displayed on this site are gathered automatically from third-party websites. If you are a copyright owner and believe that any content found through Movora violates your rights, please be aware that we do not control or host any of the content. Any copyright infringement claims should be directed to the respective third-party sites where the content is hosted. For any DMCA takedown requests, please contact the original content provider or hosting website.
        </p>
      </div>
    </footer>
  );
}
