import React from 'react';

export function Footer() {
  return (
    <footer className="mt-auto border-t border-border/20 py-8 bg-background">
      <div className="container mx-auto px-4 text-center text-muted-foreground">
        <p>&copy; {new Date().getFullYear()} Movora. All Rights Reserved.</p>
      </div>
    </footer>
  );
}