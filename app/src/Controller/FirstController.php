<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;

class FirstController
{
    public function startpage(): Response
    {
        return new Response('My Default Response');
    }

}
