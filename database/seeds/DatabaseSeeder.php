<?php

use App\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        // $this->call(UsersTableSeeder::class);
        User::create([
            "name"=> "lars",
            "email"=> "goetia@mimail.com",
            "password"=> bcrypt("password"),
        ]);
        User::create([
            "name"=> "heri",
            "email"=> "heri@mimail.com",
            "password"=> bcrypt("password"),
        ]);
    }
}
