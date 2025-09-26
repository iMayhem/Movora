import React from 'react';
import { VideoServerType, getActiveServers } from '@/lib/video-servers';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Server, Check } from 'lucide-react';

interface ServerSelectorProps {
  currentServer: VideoServerType;
  onServerChange: (server: VideoServerType) => void;
  disabled?: boolean;
}

export function ServerSelector({ currentServer, onServerChange, disabled }: ServerSelectorProps) {
  const servers = getActiveServers();
  const currentServerInfo = servers.find(s => s.type === currentServer);

  if (servers.length <= 1) {
    return null; // Don't show selector if only one server
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button
          variant="outline"
          size="sm"
          disabled={disabled}
          className="bg-black/70 border-gray-600 text-white hover:bg-black/80"
        >
          <Server className="h-4 w-4 mr-2" />
          {currentServerInfo?.name || 'Select Server'}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="bg-gray-900 border-gray-700">
        {servers.map((server) => (
          <DropdownMenuItem
            key={server.type}
            onClick={() => onServerChange(server.type)}
            className="text-white hover:bg-gray-800 focus:bg-gray-800"
          >
            <div className="flex items-center w-full">
              {currentServer === server.type ? (
                <Check className="h-4 w-4 mr-2 text-green-400" />
              ) : (
                <div className="h-4 w-4 mr-2" />
              )}
              <span>{server.name}</span>
            </div>
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}


