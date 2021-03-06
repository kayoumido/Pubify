<?php

use App\Controllers\Admin\HappyHourController;
use App\Middlewares\AuthMiddleware;
use App\Middlewares\HasRoleMiddleware;

// the keyword "use" -> to do a parameter inheritance to a closure
$app->group('/admin', function () use ($container) {
    $this
        ->get('/happyhours', HappyHourController::class.":indexAction")
        ->setName("admin_happyhours_index");
    $this
        ->get('/happyhours/create', HappyHourController::class.":createAction")
        ->setName("admin_happyhours_create");
    $this
        ->post('/happyhours', HappyHourController::class.":storeAction")
        ->setName("admin_happyhours_store");
})
    ->add(new AuthMiddleware($container))
    ->add(new HasRoleMiddleware($container, "manager"));