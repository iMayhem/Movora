/** @type {import('next').NextConfig} */
const nextConfig = {
    images: {
        remotePatterns: [
            {
                protocol: 'https',
                hostname: 'image.tmdb.org',
            },
            {
                protocol: 'https',
                hostname: 'placehold.co',
            },
            {
                protocol: 'https',
                hostname: 'images.weserv.nl',
            },
            {
                protocol: 'https',
                hostname: '*.anilist.co',
            }
        ]
    }
};

export default nextConfig;
