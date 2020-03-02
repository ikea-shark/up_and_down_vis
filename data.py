from common.helpers import parser
from common.fetch import FetchApi

# if __name__ == "__main__":
args = parser()
f = FetchApi(year=args.year,
             limit=args.limit,
             get_all=args.get_all,
             save=args.save)
f.get_records()
