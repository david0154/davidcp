<?php

declare(strict_types=1);

namespace David\WebApp\InstallationTarget;

use David\System\Util;

class TargetDomain
{
    public function __construct(
        public readonly string $domainName,
        public readonly string $domainPath,
        public readonly string $ipAddress,
        public readonly bool $isSslEnabled,
    ) {
    }

    public function getUrl(): string
    {
        return ($this->isSslEnabled ? 'https://' : 'http://') . $this->domainName;
    }

    public function getDocRoot(string $appendedPath = ''): string
    {
        return Util::joinPaths($this->domainPath, 'public_html', $appendedPath);
    }
}
