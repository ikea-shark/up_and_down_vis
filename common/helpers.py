import argparse


def parser():
    parser = argparse.ArgumentParser(description='Fetch API.')

    parser.add_argument('--year',
                        dest='year',
                        type=int,
                        help='Input the year.')

    parser.add_argument('--limit',
                        dest='limit',
                        type=int,
                        help='Input the limit.')

    parser.add_argument('--all',
                        action='store_true',
                        dest='get_all',
                        default=False,
                        help='Get all data')

    parser.add_argument('--save',
                        dest='save',
                        type=str,
                        help='Input txt or sql')
    args = parser.parse_args()
    return args
