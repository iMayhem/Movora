import { Loader } from 'lucide-react';

export function PageLoader() {
  return (
    <div className="fixed inset-0 bg-background/80 backdrop-blur-sm flex items-center justify-center z-50">
      <Loader className="animate-spin h-12 w-12 text-primary" />
    </div>
  );
}
