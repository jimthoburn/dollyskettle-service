# WordPress Blueprint _beta_

Also see: https://github.com/render-examples/wordpress

This is example code for automatically setting up a WordPress site with Docker and version-controlled backups.

It’s a work in progress. 🚧

You can use the included [blueprint](https://render.com/docs/infrastructure-as-code) to host this on [Render](https://render.com/).

This works together with a separate [content repository](https://github.com/jimthoburn/wordpress-content-example) that has the WordPress files, uploads and a MySQL backup file.

The basic steps to get it working are:

1. Fork this repository and the [content repository](https://github.com/jimthoburn/wordpress-content-example). You may want to make them both private. 🔐
2. Create a new GitHub account that only has access to your content repository.
3. Generate a new SSH key and add it to your new GitHub account.
4. In your Render dashboard, create a new environment group, following the “wordpress-settings” example in: https://github.com/jimthoburn/wordpress-blueprint/blob/main/render.yaml. For `GIT_REPOSITORY`, enter a value like `username/repository.git`, with the path to your forked copy of the [content repository](https://github.com/jimthoburn/wordpress-content-example). You can use the account and key you created in steps 2 and 3 for the other environment variables and secrets. And you can create an empty `known_hosts` secret file, to start out with.
5. In your Render dashboard, create a new [blueprint](https://render.com/docs/infrastructure-as-code) using your forked copy of this repository.
6. Once your services are up and running, go to the shell for your WordPress service and run the “setup” script: `sh /usr/local/bin/wordpress-setup.sh`
7. To backup your WordPress content and data, run the “backup” script: `sh /usr/local/bin/wordpress-backup.sh`

The “setup” and “backup” scripts will “clone” and “push” to your [content repository](https://github.com/jimthoburn/wordpress-content-example), respectively.

After you run the setup script in the shell, a `~/known_hosts` file should be generated in the root directory. You can copy this to your environment group (see step #4) so it will automatically be available for other instances of your blueprint, like preview environments (to avoid prompts when running setup.sh automatically).

[Git Large File Storage](https://git-lfs.github.com/) is configured automatically, to effeciently store images from the `wp-content` folder. If you have a lot of image files, you may run into [bandwidth and storage limits on GitHub](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-storage-and-bandwidth-usage).

## Troubleshooting

If you notice any SSL issues with WordPress (for example, CSS files that don’t load in a browser), you may want to copy the [wp-config-sample-render.php](https://github.com/jimthoburn/wordpress-content-example/blob/main/html/wp-config-sample-render.php) file to `wp-config.php`, or use it as a guide.

If your WordPress health check shows a “Background updates may not be working properly” message, you can add this line to your theme’s `functions.php` file:
```
// https://core.trac.wordpress.org/ticket/52279
add_filter( 'automatic_updates_is_vcs_checkout', '__return_false' );
```
